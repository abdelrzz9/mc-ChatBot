package ai

import (
	"fmt"

	"github.com/mc-club/chatbot-backend/internal/config"
)

func NewProvider(cfg *config.Config) AIProvider {
	switch cfg.AIProvider {
	case "openai":
		return NewOpenAIProvider(cfg.OpenAIAPIKey, cfg.OpenAIModel)
	case "anthropic":
		return NewAnthropicProvider(cfg.AnthropicAPIKey, cfg.AnthropicModel)
	case "ollama":
		return NewOllamaProvider(cfg.OllamaBaseURL, cfg.OllamaModel)
	default:
		panic(fmt.Sprintf("unknown AI provider: %s", cfg.AIProvider))
	}
}

func NewProviderFromSettings(providerName, openAIKey, anthropicKey, ollamaURL, ollamaModel, openAIModel, anthropicModel string) AIProvider {
	switch providerName {
	case "openai":
		model := openAIModel
		if model == "" {
			model = "gpt-4o-mini"
		}
		return NewOpenAIProvider(openAIKey, model)
	case "anthropic":
		model := anthropicModel
		if model == "" {
			model = "claude-3-haiku-20240307"
		}
		return NewAnthropicProvider(anthropicKey, model)
	case "ollama":
		if ollamaURL == "" {
			ollamaURL = "http://localhost:11434"
		}
		if ollamaModel == "" {
			ollamaModel = "llama3.2"
		}
		return NewOllamaProvider(ollamaURL, ollamaModel)
	default:
		return NewOpenAIProvider(openAIKey, "gpt-4o-mini")
	}
}
