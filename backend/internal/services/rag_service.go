package services

import (
	"context"
	"fmt"
	"strings"
	"unicode"

	"github.com/rs/zerolog/log"

	"github.com/mc-club/chatbot-backend/internal/ai"
	"github.com/mc-club/chatbot-backend/internal/config"
	"github.com/mc-club/chatbot-backend/internal/models"
	"github.com/mc-club/chatbot-backend/internal/repositories"
)

type RAGService struct {
	docRepo *repositories.DocumentRepository
	cfg     *config.Config
}

func NewRAGService(cfg *config.Config, docRepo *repositories.DocumentRepository) *RAGService {
	return &RAGService{
		docRepo: docRepo,
		cfg:     cfg,
	}
}

func (s *RAGService) ProcessDocument(ctx context.Context, documentID, content, filename string) error {
	text := extractText(content, filename)
	if strings.TrimSpace(text) == "" {
		return fmt.Errorf("no extractable text found in document")
	}

	chunks := s.chunkText(text)

	var chunkModels []*models.Chunk
	for i, chunk := range chunks {
		chunkModels = append(chunkModels, &models.Chunk{
			DocumentID: documentID,
			Content:    chunk,
			ChunkIndex: i,
		})
	}

	if err := s.docRepo.CreateChunks(ctx, chunkModels); err != nil {
		return fmt.Errorf("create chunks: %w", err)
	}

	return nil
}

func (s *RAGService) SearchSimilar(ctx context.Context, query string, limit int) ([]*models.ChunkWithScore, error) {
	results, err := s.docRepo.SearchSimilarChunks(ctx, nil, limit)
	if err != nil {
		return nil, fmt.Errorf("search similar chunks: %w", err)
	}
	_ = query
	return results, nil
}

func (s *RAGService) SearchSimilarWithEmbedding(ctx context.Context, query string, provider ai.AIProvider, limit int) ([]*models.ChunkWithScore, error) {
	embedding, err := provider.GenerateEmbedding(ctx, query)
	if err != nil {
		log.Warn().Err(err).Msg("embedding failed, falling back to unranked search")
		return s.docRepo.SearchSimilarChunks(ctx, nil, limit)
	}

	results, err := s.docRepo.SearchSimilarChunks(ctx, embedding, limit)
	if err != nil {
		return nil, fmt.Errorf("search similar chunks: %w", err)
	}

	return results, nil
}

func (s *RAGService) BuildContext(chunks []*models.ChunkWithScore) string {
	var builder strings.Builder
	for i, chunk := range chunks {
		if i > 0 {
			builder.WriteString("\n\n")
		}
		builder.WriteString(chunk.Content)
	}
	return builder.String()
}

func (s *RAGService) chunkText(text string) []string {
	chunkSize := s.cfg.ChunkSize
	if chunkSize <= 0 {
		chunkSize = 500
	}

	overlap := s.cfg.ChunkOverlap
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

func extractText(content, filename string) string {
	lower := strings.ToLower(filename)
	if strings.HasSuffix(lower, ".pdf") {
		return extractPDFText(content)
	}

	return content
}

func extractPDFText(content string) string {
	var result strings.Builder
	inBuffer := false

	for _, r := range content {
		if unicode.IsPrint(r) || r == '\n' || r == '\r' || r == '\t' {
			result.WriteRune(r)
			inBuffer = true
		} else if inBuffer {
			result.WriteRune(' ')
		}
	}

	cleaned := result.String()

	lines := strings.Split(cleaned, "\n")
	var filtered []string
	for _, line := range lines {
		trimmed := strings.TrimSpace(line)
		if trimmed != "" {
			filtered = append(filtered, trimmed)
		}
	}

	return strings.Join(filtered, "\n")
}
