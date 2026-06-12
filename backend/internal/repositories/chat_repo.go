package repositories

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/mc-club/chatbot-backend/internal/models"
)

type ChatRepository struct {
	pool *pgxpool.Pool
}

func NewChatRepository(pool *pgxpool.Pool) *ChatRepository {
	return &ChatRepository{pool: pool}
}

func (r *ChatRepository) CreateConversation(ctx context.Context, userID, title string) (*models.Conversation, error) {
	conv := &models.Conversation{}
	err := r.pool.QueryRow(ctx,
		`INSERT INTO conversations (user_id, title) VALUES ($1, $2)
		 RETURNING id, user_id, title, created_at, updated_at`,
		userID, title,
	).Scan(&conv.ID, &conv.UserID, &conv.Title, &conv.CreatedAt, &conv.UpdatedAt)
	if err != nil {
		return nil, fmt.Errorf("create conversation: %w", err)
	}
	return conv, nil
}

func (r *ChatRepository) GetConversations(ctx context.Context, userID string) ([]*models.Conversation, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, user_id, title, created_at, updated_at FROM conversations
		 WHERE user_id = $1 ORDER BY updated_at DESC`,
		userID,
	)
	if err != nil {
		return nil, fmt.Errorf("get conversations: %w", err)
	}
	defer rows.Close()

	var conversations []*models.Conversation
	for rows.Next() {
		conv := &models.Conversation{}
		if err := rows.Scan(&conv.ID, &conv.UserID, &conv.Title, &conv.CreatedAt, &conv.UpdatedAt); err != nil {
			return nil, fmt.Errorf("scan conversation: %w", err)
		}
		conversations = append(conversations, conv)
	}

	return conversations, nil
}

func (r *ChatRepository) GetConversationByID(ctx context.Context, id, userID string) (*models.Conversation, error) {
	conv := &models.Conversation{}
	err := r.pool.QueryRow(ctx,
		`SELECT id, user_id, title, created_at, updated_at FROM conversations WHERE id = $1 AND user_id = $2`,
		id, userID,
	).Scan(&conv.ID, &conv.UserID, &conv.Title, &conv.CreatedAt, &conv.UpdatedAt)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get conversation: %w", err)
	}
	return conv, nil
}

func (r *ChatRepository) UpdateConversationTitle(ctx context.Context, id, title string) error {
	_, err := r.pool.Exec(ctx,
		`UPDATE conversations SET title = $1, updated_at = NOW() WHERE id = $2`,
		title, id,
	)
	if err != nil {
		return fmt.Errorf("update conversation title: %w", err)
	}
	return nil
}

func (r *ChatRepository) DeleteConversation(ctx context.Context, id, userID string) error {
	_, err := r.pool.Exec(ctx,
		`DELETE FROM conversations WHERE id = $1 AND user_id = $2`,
		id, userID,
	)
	if err != nil {
		return fmt.Errorf("delete conversation: %w", err)
	}
	return nil
}

func (r *ChatRepository) CreateMessage(ctx context.Context, conversationID, role, content string) (*models.Message, error) {
	msg := &models.Message{}
	err := r.pool.QueryRow(ctx,
		`INSERT INTO messages (conversation_id, role, content) VALUES ($1, $2, $3)
		 RETURNING id, conversation_id, role, content, created_at`,
		conversationID, role, content,
	).Scan(&msg.ID, &msg.ConversationID, &msg.Role, &msg.Content, &msg.CreatedAt)
	if err != nil {
		return nil, fmt.Errorf("create message: %w", err)
	}

	_, err = r.pool.Exec(ctx,
		`UPDATE conversations SET updated_at = NOW() WHERE id = $1`,
		conversationID,
	)
	if err != nil {
		return nil, fmt.Errorf("update conversation timestamp: %w", err)
	}

	return msg, nil
}

func (r *ChatRepository) GetMessages(ctx context.Context, conversationID string) ([]*models.Message, error) {
	rows, err := r.pool.Query(ctx,
		`SELECT id, conversation_id, role, content, created_at FROM messages
		 WHERE conversation_id = $1 ORDER BY created_at ASC`,
		conversationID,
	)
	if err != nil {
		return nil, fmt.Errorf("get messages: %w", err)
	}
	defer rows.Close()

	var messages []*models.Message
	for rows.Next() {
		msg := &models.Message{}
		if err := rows.Scan(&msg.ID, &msg.ConversationID, &msg.Role, &msg.Content, &msg.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan message: %w", err)
		}
		messages = append(messages, msg)
	}

	return messages, nil
}
