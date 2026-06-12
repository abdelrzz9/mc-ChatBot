package repositories

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/mc-club/chatbot-backend/internal/models"
)

type SettingsRepository struct {
	pool *pgxpool.Pool
}

func NewSettingsRepository(pool *pgxpool.Pool) *SettingsRepository {
	return &SettingsRepository{pool: pool}
}

func (r *SettingsRepository) GetSettings(ctx context.Context, userID string) (*models.Settings, error) {
	settings := &models.Settings{}
	err := r.pool.QueryRow(ctx,
		`SELECT id, user_id, theme, ai_provider, openai_api_key, anthropic_api_key, ollama_base_url, created_at, updated_at
		 FROM user_settings WHERE user_id = $1`,
		userID,
	).Scan(&settings.ID, &settings.UserID, &settings.Theme, &settings.AIProvider,
		&settings.OpenAIAPIKey, &settings.AnthropicAPIKey, &settings.OllamaBaseURL,
		&settings.CreatedAt, &settings.UpdatedAt)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, nil
		}
		return nil, fmt.Errorf("get settings: %w", err)
	}
	return settings, nil
}

func (r *SettingsRepository) CreateSettings(ctx context.Context, userID string) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO user_settings (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING`,
		userID,
	)
	if err != nil {
		return fmt.Errorf("create settings: %w", err)
	}
	return nil
}

func (r *SettingsRepository) UpdateSettings(ctx context.Context, userID string, req *models.UpdateSettingsRequest) error {
	query := `UPDATE user_settings SET updated_at = NOW()`
	args := make([]any, 0)
	argIdx := 1

	if req.Theme != nil {
		query += fmt.Sprintf(`, theme = $%d`, argIdx)
		args = append(args, *req.Theme)
		argIdx++
	}
	if req.AIProvider != nil {
		query += fmt.Sprintf(`, ai_provider = $%d`, argIdx)
		args = append(args, *req.AIProvider)
		argIdx++
	}
	if req.OpenAIAPIKey != nil {
		query += fmt.Sprintf(`, openai_api_key = $%d`, argIdx)
		args = append(args, *req.OpenAIAPIKey)
		argIdx++
	}
	if req.AnthropicAPIKey != nil {
		query += fmt.Sprintf(`, anthropic_api_key = $%d`, argIdx)
		args = append(args, *req.AnthropicAPIKey)
		argIdx++
	}
	if req.OllamaBaseURL != nil {
		query += fmt.Sprintf(`, ollama_base_url = $%d`, argIdx)
		args = append(args, *req.OllamaBaseURL)
		argIdx++
	}

	query += fmt.Sprintf(` WHERE user_id = $%d`, argIdx)
	args = append(args, userID)

	_, err := r.pool.Exec(ctx, query, args...)
	if err != nil {
		return fmt.Errorf("update settings: %w", err)
	}
	return nil
}
