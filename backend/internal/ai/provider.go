package ai

import "context"

type ChatMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type AIProvider interface {
	GenerateChat(ctx context.Context, messages []ChatMessage, systemPrompt string) (<-chan string, error)
	GenerateEmbedding(ctx context.Context, text string) ([]float64, error)
	Name() string
}
