package routes

import (
	"encoding/json"
	"fmt"
	"net/http"
	"sort"
	"sync"

	"github.com/mc-club/chatbot-backend/internal/models"
	"github.com/mc-club/chatbot-backend/internal/services"
)

var (
	sessionsMu sync.RWMutex
	sessions   = make(map[string]*models.ChatSession)
	messagesMu sync.RWMutex
	messages   = make(map[string][]models.ChatMessage)
)

func listSessionsHandler(w http.ResponseWriter, r *http.Request) {
	sessionsMu.RLock()
	defer sessionsMu.RUnlock()

	list := make([]models.ChatSession, 0, len(sessions))
	for _, s := range sessions {
		list = append(list, *s)
	}

	sort.Slice(list, func(i, j int) bool {
		return list[i].UpdatedAt > list[j].UpdatedAt
	})

	writeJSON(w, http.StatusOK, models.SessionListResponse{Sessions: list})
}

func createSessionHandler(w http.ResponseWriter, r *http.Request) {
	var req models.CreateSessionRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	id := fmt.Sprintf("session_%d", models.NowMillis())
	now := models.NowMillis()
	title := req.Title
	if title == "" {
		title = fmt.Sprintf("Chat %d", len(sessions)+1)
	}

	session := &models.ChatSession{
		ID:        id,
		Title:     title,
		CreatedAt: now,
		UpdatedAt: now,
	}

	sessionsMu.Lock()
	sessions[id] = session
	sessionsMu.Unlock()

	messagesMu.Lock()
	messages[id] = make([]models.ChatMessage, 0)
	messagesMu.Unlock()

	writeJSON(w, http.StatusCreated, models.CreateSessionResponse{
		ID:        id,
		Title:     title,
		CreatedAt: now,
		UpdatedAt: now,
	})
}

func deleteSessionHandler(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")

	sessionsMu.Lock()
	delete(sessions, id)
	sessionsMu.Unlock()

	messagesMu.Lock()
	delete(messages, id)
	messagesMu.Unlock()

	writeJSON(w, http.StatusOK, models.DeleteResponse{
		Success: true,
		Message: "Session deleted",
	})
}

func getSessionMessagesHandler(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")

	messagesMu.RLock()
	msgs := messages[id]
	messagesMu.RUnlock()

	if msgs == nil {
		msgs = []models.ChatMessage{}
	}

	writeJSON(w, http.StatusOK, models.MessageListResponse{Messages: msgs})
}

func sendMessageHandler(w http.ResponseWriter, r *http.Request) {
	var req models.SendMessageRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	sessionsMu.RLock()
	_, exists := sessions[req.SessionID]
	sessionsMu.RUnlock()

	if !exists {
		writeError(w, http.StatusNotFound, "Session not found")
		return
	}

	now := models.NowMillis()

	userMsg := models.ChatMessage{
		ID:        fmt.Sprintf("msg_%d_%d", now, 0),
		SessionID: req.SessionID,
		Content:   req.Content,
		Role:      "user",
		Timestamp: now,
	}

	messagesMu.Lock()
	messages[req.SessionID] = append(messages[req.SessionID], userMsg)
	messagesMu.Unlock()

	answer, _ := services.RAG.Query(req.Content)

	assistantNow := models.NowMillis()
	assistantMsg := models.ChatMessage{
		ID:        fmt.Sprintf("msg_%d_%d", assistantNow, 1),
		SessionID: req.SessionID,
		Content:   answer,
		Role:      "assistant",
		Timestamp: assistantNow,
	}

	messagesMu.Lock()
	messages[req.SessionID] = append(messages[req.SessionID], assistantMsg)
	messagesMu.Unlock()

	sessionsMu.Lock()
	if s, ok := sessions[req.SessionID]; ok {
		s.UpdatedAt = assistantNow
	}
	sessionsMu.Unlock()

	writeJSON(w, http.StatusOK, models.SendMessageResponse{
		ID:        assistantMsg.ID,
		SessionID: req.SessionID,
		Content:   answer,
		Role:      "assistant",
		Timestamp: assistantNow,
	})
}
