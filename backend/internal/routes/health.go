package routes

import (
	"encoding/json"
	"net/http"

	"github.com/mc-club/chatbot-backend/internal/config"
	"github.com/mc-club/chatbot-backend/internal/models"
	"github.com/mc-club/chatbot-backend/internal/services"
)

func healthHandler(w http.ResponseWriter, r *http.Request) {
	cfg := config.Load()

	resp := models.HealthResponse{
		Status:           "ok",
		Version:          "1.0.0",
		GeminiConfigured: cfg.GeminiAPIKey != "",
		DocumentsCount:   services.RAG.DocumentCount(),
	}

	writeJSON(w, http.StatusOK, resp)
}

func writeJSON(w http.ResponseWriter, status int, data any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(data)
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]string{"error": message})
}
