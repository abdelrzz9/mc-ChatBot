package services

import (
	"github.com/mc-club/chatbot-backend/internal/config"
)

var RAG *RAGService

func InitRAG(cfg *config.Config) error {
	var err error
	RAG, err = NewRAGService(cfg)
	if err != nil {
		return err
	}
	return nil
}
