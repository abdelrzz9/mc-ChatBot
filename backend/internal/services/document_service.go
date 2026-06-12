package services

import (
	"context"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/google/uuid"
	"github.com/rs/zerolog/log"

	"github.com/mc-club/chatbot-backend/internal/config"
	"github.com/mc-club/chatbot-backend/internal/models"
	"github.com/mc-club/chatbot-backend/internal/repositories"
)

type DocumentService struct {
	cfg      *config.Config
	docRepo  *repositories.DocumentRepository
	ragSvc   *RAGService
}

func NewDocumentService(cfg *config.Config, docRepo *repositories.DocumentRepository, ragSvc *RAGService) *DocumentService {
	return &DocumentService{
		cfg:     cfg,
		docRepo: docRepo,
		ragSvc:  ragSvc,
	}
}

var allowedMimeTypes = map[string]bool{
	"text/plain":            true,
	"application/pdf":       true,
	"application/msword":    true,
	"application/vnd.openxmlformats-officedocument.wordprocessingml.document": true,
}

func (s *DocumentService) Upload(ctx context.Context, userID string, filename string, contentType string, file io.Reader) (*models.Document, error) {
	if !allowedMimeTypes[contentType] && !isAllowedExtension(filename) {
		return nil, errors.New("file type not supported. Supported types: txt, pdf, doc, docx")
	}

	data, err := io.ReadAll(file)
	if err != nil {
		return nil, fmt.Errorf("read file: %w", err)
	}

	if int64(len(data)) > s.cfg.UploadMaxSize {
		return nil, fmt.Errorf("file exceeds max upload size of %d bytes", s.cfg.UploadMaxSize)
	}

	doc, err := s.docRepo.CreateDocument(ctx, userID, filename, contentType, int64(len(data)))
	if err != nil {
		return nil, fmt.Errorf("create document record: %w", err)
	}

	uploadDir := filepath.Join(s.cfg.DataDir, "uploads", userID)
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		return nil, fmt.Errorf("create upload dir: %w", err)
	}

	ext := filepath.Ext(filename)
	storedPath := filepath.Join(uploadDir, doc.ID+ext)
	if err := os.WriteFile(storedPath, data, 0644); err != nil {
		return nil, fmt.Errorf("save file: %w", err)
	}

	if err := s.docRepo.UpdateDocumentStatus(ctx, doc.ID, "processing"); err != nil {
		log.Warn().Err(err).Msg("failed to update document status")
	}

	if err := s.ragSvc.ProcessDocument(ctx, doc.ID, string(data), filename); err != nil {
		log.Warn().Err(err).Str("document_id", doc.ID).Msg("RAG processing failed")
		s.docRepo.UpdateDocumentStatus(ctx, doc.ID, "failed")
		return doc, fmt.Errorf("process document: %w", err)
	}

	if err := s.docRepo.UpdateDocumentStatus(ctx, doc.ID, "completed"); err != nil {
		log.Warn().Err(err).Msg("failed to update document status")
	}

	return doc, nil
}

func (s *DocumentService) ListDocuments(ctx context.Context, userID string) ([]*models.Document, error) {
	return s.docRepo.GetDocuments(ctx, userID)
}

func (s *DocumentService) DeleteDocument(ctx context.Context, userID, id string) error {
	doc, err := s.docRepo.GetDocumentByID(ctx, id, userID)
	if err != nil {
		return fmt.Errorf("get document: %w", err)
	}
	if doc == nil {
		return errors.New("document not found")
	}

	if err := s.docRepo.DeleteChunksByDocumentID(ctx, id); err != nil {
		log.Warn().Err(err).Msg("failed to delete chunks")
	}

	if err := s.docRepo.DeleteDocument(ctx, id, userID); err != nil {
		return fmt.Errorf("delete document: %w", err)
	}

	ext := filepath.Ext(doc.Filename)
	storedPath := filepath.Join(s.cfg.DataDir, "uploads", userID, doc.ID+ext)
	os.Remove(storedPath)

	return nil
}

func (s *DocumentService) Reindex(ctx context.Context, userID, id string) error {
	doc, err := s.docRepo.GetDocumentByID(ctx, id, userID)
	if err != nil {
		return fmt.Errorf("get document: %w", err)
	}
	if doc == nil {
		return errors.New("document not found")
	}

	ext := filepath.Ext(doc.Filename)
	storedPath := filepath.Join(s.cfg.DataDir, "uploads", userID, doc.ID+ext)

	data, err := os.ReadFile(storedPath)
	if err != nil {
		return fmt.Errorf("read stored file: %w", err)
	}

	if err := s.docRepo.DeleteChunksByDocumentID(ctx, id); err != nil {
		log.Warn().Err(err).Msg("failed to delete existing chunks")
	}

	if err := s.docRepo.UpdateDocumentStatus(ctx, doc.ID, "processing"); err != nil {
		log.Warn().Err(err).Msg("failed to update status")
	}

	if err := s.ragSvc.ProcessDocument(ctx, doc.ID, string(data), doc.Filename); err != nil {
		s.docRepo.UpdateDocumentStatus(ctx, doc.ID, "failed")
		return fmt.Errorf("reprocess document: %w", err)
	}

	return s.docRepo.UpdateDocumentStatus(ctx, doc.ID, "completed")
}

func isAllowedExtension(filename string) bool {
	ext := strings.ToLower(filepath.Ext(filename))
	switch ext {
	case ".txt", ".pdf", ".doc", ".docx":
		return true
	default:
		return false
	}
}

func safeFilename() string {
	return uuid.New().String()
}
