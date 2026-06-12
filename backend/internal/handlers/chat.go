package handlers

import (
	"fmt"
	"io"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/rs/zerolog/log"

	"github.com/mc-club/chatbot-backend/internal/ai"
	"github.com/mc-club/chatbot-backend/internal/models"
	"github.com/mc-club/chatbot-backend/internal/services"
)

type ChatHandler struct {
	chatService *services.ChatService
	ragSvc      *services.RAGService
	provider    ai.AIProvider
	settingsSvc *services.SettingsService
}

func NewChatHandler(chatService *services.ChatService, ragSvc *services.RAGService, provider ai.AIProvider, settingsSvc *services.SettingsService) *ChatHandler {
	return &ChatHandler{
		chatService: chatService,
		ragSvc:      ragSvc,
		provider:    provider,
		settingsSvc: settingsSvc,
	}
}

// ListConversations returns all conversations for the user
// @Summary List conversations
// @Tags chat
// @Security BearerAuth
// @Produce json
// @Success 200 {array} models.Conversation
// @Failure 401 {object} map[string]string
// @Router /api/v1/conversations [get]
func (h *ChatHandler) ListConversations(c *gin.Context) {
	userID, _ := c.Get("user_id")

	convs, err := h.chatService.GetConversations(c.Request.Context(), userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"conversations": convs})
}

// CreateConversation creates a new conversation
// @Summary Create conversation
// @Tags chat
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param request body models.CreateConversationRequest true "Conversation details"
// @Success 201 {object} models.Conversation
// @Failure 400 {object} map[string]string
// @Router /api/v1/conversations [post]
func (h *ChatHandler) CreateConversation(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req models.CreateConversationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	conv, err := h.chatService.CreateConversation(c.Request.Context(), userID.(string), req.Title)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, conv)
}

// RenameConversation renames a conversation
// @Summary Rename conversation
// @Tags chat
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param id path string true "Conversation ID"
// @Param request body models.RenameConversationRequest true "New title"
// @Success 200 {object} map[string]string
// @Failure 400 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Router /api/v1/conversations/{id} [put]
func (h *ChatHandler) RenameConversation(c *gin.Context) {
	userID, _ := c.Get("user_id")
	id := c.Param("id")

	var req models.RenameConversationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.chatService.RenameConversation(c.Request.Context(), userID.(string), id, req.Title); err != nil {
		if err.Error() == "conversation not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "conversation renamed"})
}

// DeleteConversation deletes a conversation
// @Summary Delete conversation
// @Tags chat
// @Security BearerAuth
// @Produce json
// @Param id path string true "Conversation ID"
// @Success 200 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Router /api/v1/conversations/{id} [delete]
func (h *ChatHandler) DeleteConversation(c *gin.Context) {
	userID, _ := c.Get("user_id")
	id := c.Param("id")

	if err := h.chatService.DeleteConversation(c.Request.Context(), userID.(string), id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "conversation deleted"})
}

// GetMessages returns messages for a conversation
// @Summary Get conversation messages
// @Tags chat
// @Security BearerAuth
// @Produce json
// @Param id path string true "Conversation ID"
// @Success 200 {array} models.Message
// @Failure 401 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Router /api/v1/conversations/{id}/messages [get]
func (h *ChatHandler) GetMessages(c *gin.Context) {
	id := c.Param("id")

	msgs, err := h.chatService.GetMessages(c.Request.Context(), id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"messages": msgs})
}

// SendMessage sends a message and streams the response via SSE
// @Summary Send message and get AI response (SSE)
// @Tags chat
// @Security BearerAuth
// @Accept json
// @Produce text/event-stream
// @Param request body models.SendMessageRequest true "Message details"
// @Success 200 {string} string "SSE stream of tokens"
// @Failure 400 {object} map[string]string
// @Router /api/v1/chat/send [post]
func (h *ChatHandler) SendMessage(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req models.SendMessageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	provider, err := h.getProviderForUser(c, userID.(string))
	if err != nil {
		log.Warn().Err(err).Str("user_id", userID.(string)).Msg("failed to get user provider, using default")
		provider = h.provider
	}

	stream, err := h.chatService.ProcessMessage(c.Request.Context(), provider, req.ConversationID, userID.(string), req.Content)
	if err != nil {
		if err.Error() == "conversation not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.Writer.Header().Set("Content-Type", "text/event-stream")
	c.Writer.Header().Set("Cache-Control", "no-cache")
	c.Writer.Header().Set("Connection", "keep-alive")
	c.Writer.WriteHeader(http.StatusOK)

	flusher, ok := c.Writer.(http.Flusher)
	if !ok {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "streaming not supported"})
		return
	}

	for token := range stream {
		_, err := fmt.Fprintf(c.Writer, "data: %s\n\n", token)
		if err != nil {
			return
		}
		flusher.Flush()
	}

	fmt.Fprintf(c.Writer, "data: [DONE]\n\n")
	flusher.Flush()
}

func (h *ChatHandler) getProviderForUser(c *gin.Context, userID string) (ai.AIProvider, error) {
	settings, err := h.settingsSvc.GetSettings(c.Request.Context(), userID)
	if err != nil {
		return nil, err
	}

	provider := settings.AIProvider
	if provider == "" {
		return nil, fmt.Errorf("no provider configured")
	}

	openAIKey := settings.OpenAIAPIKey
	anthropicKey := settings.AnthropicAPIKey
	ollamaURL := settings.OllamaBaseURL

	return ai.NewProviderFromSettings(provider, openAIKey, anthropicKey, ollamaURL, "", "", ""), nil
}

func convertToString(reader io.Reader) string {
	data, _ := io.ReadAll(reader)
	return strings.TrimSpace(string(data))
}
