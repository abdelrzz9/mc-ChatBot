package routes

import (
	"net/http"

	"github.com/mc-club/chatbot-backend/internal/config"
)

func Setup(cfg *config.Config) http.Handler {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /api/health", healthHandler)

	mux.HandleFunc("GET /api/chat/sessions", listSessionsHandler)
	mux.HandleFunc("POST /api/chat/sessions", createSessionHandler)
	mux.HandleFunc("DELETE /api/chat/sessions/{id}", deleteSessionHandler)
	mux.HandleFunc("GET /api/chat/sessions/{id}/messages", getSessionMessagesHandler)
	mux.HandleFunc("POST /api/chat/message", sendMessageHandler)

	mux.HandleFunc("GET /api/documents", listDocumentsHandler)
	mux.HandleFunc("POST /api/documents/upload", uploadDocumentHandler)
	mux.HandleFunc("DELETE /api/documents/{filename}", deleteDocumentHandler)

	return corsMiddleware(mux, cfg.CORSOrigins)
}

func corsMiddleware(next http.Handler, origins []string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		for _, allowed := range origins {
			if allowed == "*" || allowed == origin {
				w.Header().Set("Access-Control-Allow-Origin", origin)
				break
			}
		}
		if origin == "" {
			w.Header().Set("Access-Control-Allow-Origin", "*")
		}

		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		w.Header().Set("Access-Control-Allow-Credentials", "true")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}
