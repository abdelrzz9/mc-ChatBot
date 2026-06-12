package models

import "time"

type Settings struct {
	ID              string    `db:"id" json:"id"`
	UserID          string    `db:"user_id" json:"user_id"`
	Theme           string    `db:"theme" json:"theme"`
	AIProvider      string    `db:"ai_provider" json:"ai_provider"`
	OpenAIAPIKey    string    `db:"openai_api_key" json:"openai_api_key,omitempty"`
	AnthropicAPIKey string    `db:"anthropic_api_key" json:"anthropic_api_key,omitempty"`
	OllamaBaseURL   string    `db:"ollama_base_url" json:"ollama_base_url,omitempty"`
	CreatedAt       time.Time `db:"created_at" json:"created_at"`
	UpdatedAt       time.Time `db:"updated_at" json:"updated_at"`
}

type UpdateSettingsRequest struct {
	Theme           *string `json:"theme,omitempty"`
	AIProvider      *string `json:"ai_provider,omitempty"`
	OpenAIAPIKey    *string `json:"openai_api_key,omitempty"`
	AnthropicAPIKey *string `json:"anthropic_api_key,omitempty"`
	OllamaBaseURL   *string `json:"ollama_base_url,omitempty"`
}
