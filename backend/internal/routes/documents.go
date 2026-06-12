package routes

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"

	"github.com/mc-club/chatbot-backend/internal/config"
	"github.com/mc-club/chatbot-backend/internal/models"
	"github.com/mc-club/chatbot-backend/internal/services"
)

func listDocumentsHandler(w http.ResponseWriter, r *http.Request) {
	docs := services.RAG.ListDocuments()
	if docs == nil {
		docs = []services.DocumentMeta{}
	}

	result := make([]models.DocumentInfo, len(docs))
	for i, d := range docs {
		result[i] = models.DocumentInfo{
			ID:          d.ID,
			Filename:    d.Filename,
			ContentType: d.ContentType,
			Size:        d.Size,
			CreatedAt:   d.CreatedAt,
			ChunkCount:  d.ChunkCount,
		}
	}

	writeJSON(w, http.StatusOK, models.DocumentListResponse{Documents: result})
}

func uploadDocumentHandler(w http.ResponseWriter, r *http.Request) {
	cfg := config.Load()

	r.Body = http.MaxBytesReader(w, r.Body, cfg.MaxUploadSizeMB*1024*1024)

	if err := r.ParseMultipartForm(cfg.MaxUploadSizeMB * 1024 * 1024); err != nil {
		writeError(w, http.StatusBadRequest, "File too large or invalid form data")
		return
	}

	file, header, err := r.FormFile("file")
	if err != nil {
		writeError(w, http.StatusBadRequest, "No file provided")
		return
	}
	defer file.Close()

	content, err := io.ReadAll(file)
	if err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to read file")
		return
	}

	textContent := string(content)

	uploadDir := filepath.Join(cfg.DataDir, "uploads")
	os.MkdirAll(uploadDir, 0755)

	filePath := filepath.Join(uploadDir, header.Filename)
	if err := os.WriteFile(filePath, content, 0644); err != nil {
		writeError(w, http.StatusInternalServerError, "Failed to save file")
		return
	}

	docID, chunkCount, err := services.RAG.AddDocument(
		textContent,
		header.Filename,
		header.Header.Get("Content-Type"),
		int64(len(content)),
		models.NowMillis(),
	)
	if err != nil {
		writeError(w, http.StatusInternalServerError, fmt.Sprintf("Failed to index document: %v", err))
		return
	}

	writeJSON(w, http.StatusCreated, models.UploadResponse{
		Success:    true,
		Filename:   header.Filename,
		Chunks:     chunkCount,
		DocumentID: docID,
	})
}

func deleteDocumentHandler(w http.ResponseWriter, r *http.Request) {
	filename := r.PathValue("filename")

	cfg := config.Load()
	filePath := filepath.Join(cfg.DataDir, "uploads", filename)
	os.Remove(filePath)

	if !services.RAG.DeleteDocument(filename) {
		writeError(w, http.StatusNotFound, "Document not found")
		return
	}

	writeJSON(w, http.StatusOK, models.DeleteResponse{
		Success: true,
		Message: fmt.Sprintf("Document '%s' deleted successfully", filename),
	})
}
