package services

import (
	"context"
	"errors"
	"fmt"

	"github.com/rs/zerolog/log"

	"github.com/mc-club/chatbot-backend/internal/ai"
	"github.com/mc-club/chatbot-backend/internal/models"
	"github.com/mc-club/chatbot-backend/internal/repositories"
)

type ChatService struct {
	chatRepo *repositories.ChatRepository
	ragSvc   *RAGService
}

func NewChatService(chatRepo *repositories.ChatRepository, ragSvc *RAGService) *ChatService {
	return &ChatService{
		chatRepo: chatRepo,
		ragSvc:   ragSvc,
	}
}

func (s *ChatService) CreateConversation(ctx context.Context, userID, title string) (*models.Conversation, error) {
	if title == "" {
		title = "New Chat"
	}
	return s.chatRepo.CreateConversation(ctx, userID, title)
}

func (s *ChatService) RenameConversation(ctx context.Context, userID, id, title string) error {
	conv, err := s.chatRepo.GetConversationByID(ctx, id, userID)
	if err != nil {
		return fmt.Errorf("get conversation: %w", err)
	}
	if conv == nil {
		return errors.New("conversation not found")
	}
	return s.chatRepo.UpdateConversationTitle(ctx, id, title)
}

func (s *ChatService) DeleteConversation(ctx context.Context, userID, id string) error {
	return s.chatRepo.DeleteConversation(ctx, id, userID)
}

func (s *ChatService) GetConversations(ctx context.Context, userID string) ([]*models.Conversation, error) {
	return s.chatRepo.GetConversations(ctx, userID)
}

func (s *ChatService) GetConversation(ctx context.Context, id, userID string) (*models.Conversation, error) {
	return s.chatRepo.GetConversationByID(ctx, id, userID)
}

func (s *ChatService) GetMessages(ctx context.Context, conversationID string) ([]*models.Message, error) {
	return s.chatRepo.GetMessages(ctx, conversationID)
}

func (s *ChatService) CreateMessage(ctx context.Context, conversationID, role, content string) (*models.Message, error) {
	return s.chatRepo.CreateMessage(ctx, conversationID, role, content)
}

func (s *ChatService) ProcessMessage(ctx context.Context, provider ai.AIProvider, conversationID, userID, content string) (<-chan string, error) {
	conv, err := s.chatRepo.GetConversationByID(ctx, conversationID, userID)
	if err != nil {
		return nil, fmt.Errorf("get conversation: %w", err)
	}
	if conv == nil {
		return nil, errors.New("conversation not found")
	}

	userMsg, err := s.chatRepo.CreateMessage(ctx, conversationID, "user", content)
	if err != nil {
		return nil, fmt.Errorf("save user message: %w", err)
	}
	_ = userMsg

	history, err := s.chatRepo.GetMessages(ctx, conversationID)
	if err != nil {
		return nil, fmt.Errorf("get message history: %w", err)
	}

	ragContext, err := s.ragSvc.SearchSimilar(ctx, content, 4)
	if err != nil {
		log.Warn().Err(err).Msg("RAG search failed, continuing without context")
	}

	systemPrompt := "You are a helpful AI assistant. Answer questions concisely and accurately."
	if ragContext != nil && len(ragContext) > 0 {
		contextStr := buildRAGContext(ragContext)
		systemPrompt = fmt.Sprintf(`You are a helpful AI assistant. Use the following context to answer the user's question. If the context doesn't contain enough information, say so clearly.

Context:
%s`, contextStr)
	}

	aiMessages := make([]ai.ChatMessage, 0, len(history))
	for _, msg := range history {
		aiMessages = append(aiMessages, ai.ChatMessage{
			Role:    msg.Role,
			Content: msg.Content,
		})
	}

	stream, err := provider.GenerateChat(ctx, aiMessages, systemPrompt)
	if err != nil {
		return nil, fmt.Errorf("generate chat: %w", err)
	}

	out := make(chan string)
	go func() {
		defer close(out)

		var fullResponse string
		for token := range stream {
			fullResponse += token
			out <- token
		}

		if fullResponse != "" {
			if _, err := s.chatRepo.CreateMessage(ctx, conversationID, "assistant", fullResponse); err != nil {
				log.Warn().Err(err).Msg("failed to save assistant message")
			}
		}
	}()

	return out, nil
}

func buildRAGContext(chunks []*models.ChunkWithScore) string {
	context := ""
	for i, chunk := range chunks {
		if i > 0 {
			context += "\n\n"
		}
		context += chunk.Content
	}
	return context
}
