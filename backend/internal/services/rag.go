package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"math"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"

	"github.com/mc-club/chatbot-backend/internal/config"
)

type Chunk struct {
	Content  string         `json:"content"`
	Metadata map[string]any `json:"metadata"`
}

type VectorEntry struct {
	ID        string
	Chunk     Chunk
	Embedding []float64
}

type RAGService struct {
	cfg        *config.Config
	mu         sync.RWMutex
	vectors    []VectorEntry
	documents  map[string]*DocumentMeta
	httpClient *http.Client
}

type DocumentMeta struct {
	ID          string `json:"id"`
	Filename    string `json:"filename"`
	ContentType string `json:"content_type"`
	Size        int64  `json:"size"`
	CreatedAt   int64  `json:"created_at"`
	ChunkCount  int    `json:"chunk_count"`
}

const geminiEmbeddingModel = "models/embedding-001"

func NewRAGService(cfg *config.Config) (*RAGService, error) {
	os.MkdirAll(cfg.DataDir, 0755)

	svc := &RAGService{
		cfg:        cfg,
		vectors:    make([]VectorEntry, 0),
		documents:  make(map[string]*DocumentMeta),
		httpClient: &http.Client{},
	}

	svc.loadFromDisk()

	log.Printf("RAG service initialized: %d documents, %d chunks", len(svc.documents), len(svc.vectors))
	return svc, nil
}

func (s *RAGService) AddDocument(content, filename, contentType string, size int64, createdAt int64) (string, int, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	docID := fmt.Sprintf("doc_%d", len(s.documents)+1)

	chunks := s.chunkText(content)

	embeddings, err := s.getEmbeddings(chunks)
	if err != nil {
		return "", 0, fmt.Errorf("embedding failed: %w", err)
	}

	for i, chunk := range chunks {
		entry := VectorEntry{
			ID: fmt.Sprintf("%s_chunk_%d", docID, i),
			Chunk: Chunk{
				Content: chunk,
				Metadata: map[string]any{
					"source":       filename,
					"content_type": contentType,
					"chunk_index":  i,
					"chunk_count":  len(chunks),
				},
			},
			Embedding: embeddings[i],
		}
		s.vectors = append(s.vectors, entry)
	}

	s.documents[filename] = &DocumentMeta{
		ID:          docID,
		Filename:    filename,
		ContentType: contentType,
		Size:        size,
		CreatedAt:   createdAt,
		ChunkCount:  len(chunks),
	}

	s.saveToDisk()
	return docID, len(chunks), nil
}

func (s *RAGService) Query(question string) (string, []map[string]string) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	if len(s.vectors) == 0 {
		return "I don't have enough information to answer that question.", nil
	}

	qEmbedding, err := s.getEmbedding(question)
	if err != nil {
		log.Printf("Query embedding failed: %v", err)
		return "I encountered an error processing your request.", nil
	}

	results := s.similaritySearch(qEmbedding, 4)

	if len(results) == 0 {
		return "I don't have enough information to answer that question.", nil
	}

	var contextBuilder strings.Builder
	for i, r := range results {
		if i > 0 {
			contextBuilder.WriteString("\n\n")
		}
		contextBuilder.WriteString(r.Chunk.Content)
	}
	context := contextBuilder.String()

	var sources []map[string]string
	for _, r := range results {
		source, _ := r.Chunk.Metadata["source"].(string)
		content := r.Chunk.Content
		if len(content) > 200 {
			content = content[:200]
		}
		sources = append(sources, map[string]string{
			"content": content,
			"source":  source,
		})
	}

	if s.cfg.GeminiAPIKey == "" {
		return fmt.Sprintf("Based on the available information:\n\n%s", context), sources
	}

	answer, err := s.askGemini(question, context)
	if err != nil {
		log.Printf("Gemini query failed: %v, falling back to context", err)
		return fmt.Sprintf("Based on the available information:\n\n%s", context), sources
	}

	return answer, sources
}

func (s *RAGService) ListDocuments() []DocumentMeta {
	s.mu.RLock()
	defer s.mu.RUnlock()

	result := make([]DocumentMeta, 0, len(s.documents))
	for _, meta := range s.documents {
		result = append(result, *meta)
	}
	return result
}

func (s *RAGService) DocumentCount() int {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return len(s.documents)
}

func (s *RAGService) DeleteDocument(filename string) bool {
	s.mu.Lock()
	defer s.mu.Unlock()

	if _, exists := s.documents[filename]; !exists {
		return false
	}

	filtered := make([]VectorEntry, 0, len(s.vectors))
	for _, v := range s.vectors {
		source, _ := v.Chunk.Metadata["source"].(string)
		if source != filename {
			filtered = append(filtered, v)
		}
	}
	s.vectors = filtered
	delete(s.documents, filename)

	s.saveToDisk()
	return true
}

func (s *RAGService) chunkText(text string) []string {
	chunkSize := s.cfg.ChunkSize
	overlap := s.cfg.ChunkOverlap

	if chunkSize <= 0 {
		chunkSize = 500
	}
	if overlap < 0 || overlap >= chunkSize {
		overlap = chunkSize / 10
	}

	textRunes := []rune(text)
	if len(textRunes) <= chunkSize {
		return []string{text}
	}

	var chunks []string
	start := 0

	for start < len(textRunes) {
		end := start + chunkSize
		if end > len(textRunes) {
			end = len(textRunes)
		}

		chunk := string(textRunes[start:end])
		chunks = append(chunks, chunk)

		if end >= len(textRunes) {
			break
		}

		start = end - overlap
		if start < 0 {
			start = 0
		}
	}

	return chunks
}

func (s *RAGService) getEmbedding(text string) ([]float64, error) {
	embeddings, err := s.getEmbeddings([]string{text})
	if err != nil {
		return nil, err
	}
	return embeddings[0], nil
}

func (s *RAGService) getEmbeddings(texts []string) ([][]float64, error) {
	if s.cfg.GeminiAPIKey != "" {
		return s.geminiEmbeddings(texts)
	}
	return s.simpleEmbeddings(texts), nil
}

func (s *RAGService) simpleEmbeddings(texts []string) [][]float64 {
	embeddings := make([][]float64, len(texts))
	for i, text := range texts {
		embeddings[i] = simpleEmbed(text)
	}
	return embeddings
}

func (s *RAGService) geminiEmbeddings(texts []string) ([][]float64, error) {
	var requests []map[string]any
	for _, text := range texts {
		requests = append(requests, map[string]any{
			"model": geminiEmbeddingModel,
			"content": map[string]any{
				"parts": []map[string]any{
					{"text": text},
				},
			},
		})
	}

	body := map[string]any{"requests": requests}
	data, err := json.Marshal(body)
	if err != nil {
		return nil, err
	}

	url := fmt.Sprintf(
		"https://generativelanguage.googleapis.com/v1beta/models/embedding-001:batchEmbedContents?key=%s",
		s.cfg.GeminiAPIKey,
	)

	req, err := http.NewRequest("POST", url, bytes.NewReader(data))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("Gemini embedding API error %d: %s", resp.StatusCode, string(respBody))
	}

	var result struct {
		Embeddings []struct {
			Values []float64 `json:"values"`
		} `json:"embeddings"`
	}

	if err := json.Unmarshal(respBody, &result); err != nil {
		return nil, err
	}

	embeddings := make([][]float64, len(result.Embeddings))
	for i, e := range result.Embeddings {
		embeddings[i] = e.Values
	}

	return embeddings, nil
}

func (s *RAGService) askGemini(question, context string) (string, error) {
	systemPrompt := fmt.Sprintf(`You are a helpful AI assistant for Micro Club. Answer questions based on the provided context.
If the context doesn't contain enough information, say so clearly.
Be concise and accurate.

Context:
%s`, context)

	body := map[string]any{
		"system_instruction": map[string]any{
			"parts": []map[string]any{
				{"text": systemPrompt},
			},
		},
		"contents": []map[string]any{
			{
				"role": "user",
				"parts": []map[string]any{
					{"text": question},
				},
			},
		},
		"generationConfig": map[string]any{
			"temperature": 0.3,
			"maxOutputTokens": 1024,
		},
	}

	data, err := json.Marshal(body)
	if err != nil {
		return "", err
	}

	url := fmt.Sprintf(
		"https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s",
		s.cfg.GeminiModel,
		s.cfg.GeminiAPIKey,
	)

	req, err := http.NewRequest("POST", url, bytes.NewReader(data))
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	if resp.StatusCode != 200 {
		return "", fmt.Errorf("Gemini API error %d: %s", resp.StatusCode, string(respBody))
	}

	var result struct {
		Candidates []struct {
			Content struct {
				Parts []struct {
					Text string `json:"text"`
				} `json:"parts"`
			} `json:"content"`
		} `json:"candidates"`
	}

	if err := json.Unmarshal(respBody, &result); err != nil {
		return "", err
	}

	if len(result.Candidates) > 0 && len(result.Candidates[0].Content.Parts) > 0 {
		return result.Candidates[0].Content.Parts[0].Text, nil
	}

	return "", fmt.Errorf("no response from Gemini")
}

func (s *RAGService) similaritySearch(queryEmbedding []float64, topK int) []VectorEntry {
	type scored struct {
		entry VectorEntry
		score float64
	}

	var scoredEntries []scored
	for _, entry := range s.vectors {
		score := cosineSimilarity(queryEmbedding, entry.Embedding)
		scoredEntries = append(scoredEntries, scored{entry, score})
	}

	for i := 0; i < len(scoredEntries); i++ {
		for j := i + 1; j < len(scoredEntries); j++ {
			if scoredEntries[j].score > scoredEntries[i].score {
				scoredEntries[i], scoredEntries[j] = scoredEntries[j], scoredEntries[i]
			}
		}
	}

	if topK > len(scoredEntries) {
		topK = len(scoredEntries)
	}

	result := make([]VectorEntry, topK)
	for i := 0; i < topK; i++ {
		result[i] = scoredEntries[i].entry
	}
	return result
}

func (s *RAGService) saveToDisk() {
	path := filepath.Join(s.cfg.DataDir, "vectors.json")

	entries := struct {
		Vectors   []VectorEntry            `json:"vectors"`
		Documents map[string]*DocumentMeta `json:"documents"`
	}{
		Vectors:   s.vectors,
		Documents: s.documents,
	}

	data, err := json.MarshalIndent(entries, "", "  ")
	if err != nil {
		log.Printf("Failed to marshal vectors: %v", err)
		return
	}

	if err := os.WriteFile(path, data, 0644); err != nil {
		log.Printf("Failed to save vectors: %v", err)
	}
}

func (s *RAGService) loadFromDisk() {
	path := filepath.Join(s.cfg.DataDir, "vectors.json")

	data, err := os.ReadFile(path)
	if err != nil {
		if !os.IsNotExist(err) {
			log.Printf("Failed to read vectors file: %v", err)
		}
		return
	}

	var entries struct {
		Vectors   []VectorEntry            `json:"vectors"`
		Documents map[string]*DocumentMeta `json:"documents"`
	}

	if err := json.Unmarshal(data, &entries); err != nil {
		log.Printf("Failed to unmarshal vectors: %v", err)
		return
	}

	s.vectors = entries.Vectors
	s.documents = entries.Documents
}

func simpleEmbed(text string) []float64 {
	dim := 128
	emb := make([]float64, dim)
	runes := []rune(text)

	for i, r := range runes {
		idx := i % dim
		emb[idx] += float64(r) / 65536.0
	}

	norm := 0.0
	for _, v := range emb {
		norm += v * v
	}
	norm = math.Sqrt(norm)
	if norm > 0 {
		for i := range emb {
			emb[i] /= norm
		}
	}

	return emb
}

func cosineSimilarity(a, b []float64) float64 {
	if len(a) != len(b) {
		return 0
	}

	dot, normA, normB := 0.0, 0.0, 0.0
	for i := range a {
		dot += a[i] * b[i]
		normA += a[i] * a[i]
		normB += b[i] * b[i]
	}

	if normA == 0 || normB == 0 {
		return 0
	}

	return dot / (math.Sqrt(normA) * math.Sqrt(normB))
}
