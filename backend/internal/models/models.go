package models

import "time"

type ChatMessage struct {
	ID        string `json:"id"`
	SessionID string `json:"session_id"`
	Content   string `json:"content"`
	Role      string `json:"role"`
	Timestamp int64  `json:"timestamp"`
}

type ChatSession struct {
	ID        string `json:"id"`
	Title     string `json:"title"`
	CreatedAt int64  `json:"created_at"`
	UpdatedAt int64  `json:"updated_at"`
}

type SendMessageRequest struct {
	SessionID string `json:"session_id"`
	Content   string `json:"content"`
}

type SendMessageResponse struct {
	ID        string `json:"id"`
	SessionID string `json:"session_id"`
	Content   string `json:"content"`
	Role      string `json:"role"`
	Timestamp int64  `json:"timestamp"`
}

type CreateSessionRequest struct {
	Title string `json:"title,omitempty"`
}

type CreateSessionResponse struct {
	ID        string `json:"id"`
	Title     string `json:"title"`
	CreatedAt int64  `json:"created_at"`
	UpdatedAt int64  `json:"updated_at"`
}

type SessionListResponse struct {
	Sessions []ChatSession `json:"sessions"`
}

type MessageListResponse struct {
	Messages []ChatMessage `json:"messages"`
}

type DocumentInfo struct {
	ID          string `json:"id"`
	Filename    string `json:"filename"`
	ContentType string `json:"content_type"`
	Size        int64  `json:"size"`
	CreatedAt   int64  `json:"created_at"`
	ChunkCount  int    `json:"chunk_count"`
}

type DocumentListResponse struct {
	Documents []DocumentInfo `json:"documents"`
}

type UploadResponse struct {
	Success    bool   `json:"success"`
	Filename   string `json:"filename"`
	Chunks     int    `json:"chunks"`
	DocumentID string `json:"document_id"`
}

type DeleteResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
}

type HealthResponse struct {
	Status           string `json:"status"`
	Version          string `json:"version"`
	GeminiConfigured bool   `json:"gemini_configured"`
	DocumentsCount   int    `json:"documents_count"`
}

func NowMillis() int64 {
	return time.Now().UnixMilli()
}
