package repositories

import (
	"context"
	"fmt"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/mc-club/chatbot-backend/internal/models"
)

type DocumentRepository struct {
	pool *pgxpool.Pool
}

func NewDocumentRepository(pool *pgxpool.Pool) *DocumentRepository {
	return &DocumentRepository{pool: pool}
}

func (r *DocumentRepository) CreateDocument(ctx context.Context, userID, filename, contentType string, sizeBytes int64) (*models.Document, error) {
	doc := &models.Document{}
	err := r.pool.QueryRow(ctx,
		`INSERT INTO documents (user_id, filename, content_type, size_bytes, status) VALUES ($1, $2, $3, $4, 'pending')
		 RETURNING id, user_id, filename, content_type, size_bytes, status, created_at, updated_at`,
		userID, filename, contentType, sizeBytes,
	).Scan(&doc.ID, &doc.UserID, &doc.Filename, &doc.ContentType, &doc.SizeBytes, &doc.Status, &doc.CreatedAt, &doc.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("create document: %w", err)
	}
	return doc, nil
}

func (r *DocumentRepository) GetDocuments(ctx context.Context, userID string) ([]*models.Document, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, user_id, filename, content_type, size_bytes, status, created_at, updated_at
		 FROM documents WHERE user_id = $1 ORDER BY created_at DESC`,
		userID,
	)
	if err != nil {
		return nil, fmt.Errorf("get documents: %w", err)
	}
	defer rows.Close()

	var docs []*models.Document
	for rows.Next() {
		doc := &models.Document{}
		if err := rows.Scan(&doc.ID, &doc.UserID, &doc.Filename, &doc.ContentType, &doc.SizeBytes, &doc.Status, &doc.CreatedAt, &doc.UpdatedAt); err != nil {
			return nil, fmt.Errorf("scan document: %w", err)
		}
		docs = append(docs, doc)
	}

	return docs, nil
}

func (r *DocumentRepository) GetDocumentByID(ctx context.Context, id, userID string) (*models.Document, error) {
	doc := &models.Document{}
	err := r.pool.QueryRow(ctx,
		`SELECT id, user_id, filename, content_type, size_bytes, status, created_at, updated_at
		 FROM documents WHERE id = $1 AND user_id = $2`,
		id, userID,
	).Scan(&doc.ID, &doc.UserID, &doc.Filename, &doc.ContentType, &doc.SizeBytes, &doc.Status, &doc.CreatedAt, &doc.UpdatedAt)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get document: %w", err)
	}
	return doc, nil
}

func (r *DocumentRepository) DeleteDocument(ctx context.Context, id, userID string) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM documents WHERE id = $1 AND user_id = $2`, id, userID)
	if err != nil {
		return fmt.Errorf("delete document: %w", err)
	}
	return nil
}

func (r *DocumentRepository) UpdateDocumentStatus(ctx context.Context, id, status string) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE documents SET status = $1, updated_at = NOW() WHERE id = $2`,
		status, id,
	)
	if err != nil {
		return fmt.Errorf("update document status: %w", err)
	}
	return nil
}

func (r *DocumentRepository) CreateChunks(ctx context.Context, chunks []*models.Chunk) error {
	if len(chunks) == 0 {
		return nil
	}

	batch := &pgx.Batch{}
	for _, chunk := range chunks {
		batch.Queue(
			`INSERT INTO chunks (document_id, content, chunk_index) VALUES ($1, $2, $3)`,
			chunk.DocumentID, chunk.Content, chunk.ChunkIndex,
		)
	}

	br := r.pool.SendBatch(ctx, batch)
	defer br.Close()

	for range chunks {
		if _, err := br.Exec(); err != nil {
			return fmt.Errorf("insert chunk: %w", err)
		}
	}

	return nil
}

func (r *DocumentRepository) UpdateChunkEmbedding(ctx context.Context, chunkID string, embedding []float64) error {
	vecStr := formatVector(embedding)
	_, err := r.pool.Exec(ctx,
		`UPDATE chunks SET embedding = $1::text::vector WHERE id = $2`,
		vecStr, chunkID,
	)
	if err != nil {
		return fmt.Errorf("update chunk embedding: %w", err)
	}
	return nil
}

func (r *DocumentRepository) GetChunksByDocumentID(ctx context.Context, documentID string) ([]*models.Chunk, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, document_id, content, chunk_index, created_at FROM chunks WHERE document_id = $1 ORDER BY chunk_index`,
		documentID,
	)
	if err != nil {
		return nil, fmt.Errorf("get chunks: %w", err)
	}
	defer rows.Close()

	var chunks []*models.Chunk
	for rows.Next() {
		chunk := &models.Chunk{}
		if err := rows.Scan(&chunk.ID, &chunk.DocumentID, &chunk.Content, &chunk.ChunkIndex, &chunk.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan chunk: %w", err)
		}
		chunks = append(chunks, chunk)
	}

	return chunks, nil
}

func (r *DocumentRepository) DeleteChunksByDocumentID(ctx context.Context, documentID string) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM chunks WHERE document_id = $1`, documentID)
	if err != nil {
		return fmt.Errorf("delete chunks: %w", err)
	}
	return nil
}

func (r *DocumentRepository) SearchSimilarChunks(ctx context.Context, embedding []float64, limit int) ([]*models.ChunkWithScore, error) {
	vecStr := formatVector(embedding)

	rows, err := r.pool.Query(ctx,
		`SELECT c.id, c.document_id, c.content, c.chunk_index, c.created_at,
		        1 - (c.embedding <=> $1::text::vector) AS similarity
		 FROM chunks c
		 WHERE c.embedding IS NOT NULL
		 ORDER BY c.embedding <=> $1::text::vector
		 LIMIT $2`,
		vecStr, limit,
	)
	if err != nil {
		return nil, fmt.Errorf("search similar chunks: %w", err)
	}
	defer rows.Close()

	var results []*models.ChunkWithScore
	for rows.Next() {
		cws := &models.ChunkWithScore{}
		if err := rows.Scan(&cws.ID, &cws.DocumentID, &cws.Content, &cws.ChunkIndex, &cws.CreatedAt, &cws.Score); err != nil {
			return nil, fmt.Errorf("scan chunk result: %w", err)
		}
		results = append(results, cws)
	}

	return results, nil
}

func formatVector(embedding []float64) string {
	parts := make([]string, len(embedding))
	for i, v := range embedding {
		parts[i] = fmt.Sprintf("%f", v)
	}
	return "[" + strings.Join(parts, ",") + "]"
}
