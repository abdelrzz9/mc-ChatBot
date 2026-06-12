package models

import "time"

type Document struct {
	ID          string    `db:"id" json:"id"`
	UserID      string    `db:"user_id" json:"user_id"`
	Filename    string    `db:"filename" json:"filename"`
	ContentType string    `db:"content_type" json:"content_type"`
	SizeBytes   int64     `db:"size_bytes" json:"size_bytes"`
	Status      string    `db:"status" json:"status"`
	CreatedAt   time.Time `db:"created_at" json:"created_at"`
	UpdatedAt   time.Time `db:"updated_at" json:"updated_at"`
}

type Chunk struct {
	ID         string    `db:"id" json:"id"`
	DocumentID string    `db:"document_id" json:"document_id"`
	Content    string    `db:"content" json:"content"`
	ChunkIndex int       `db:"chunk_index" json:"chunk_index"`
	CreatedAt  time.Time `db:"created_at" json:"created_at"`
}

type ChunkWithScore struct {
	Chunk
	Score float64 `json:"score"`
}
