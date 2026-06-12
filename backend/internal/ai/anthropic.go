package ai

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
)

type AnthropicProvider struct {
	apiKey  string
	model   string
	baseURL string
	client  *http.Client
}

type anthropicRequest struct {
	Model       string             `json:"model"`
	MaxTokens   int                `json:"max_tokens"`
	System      string             `json:"system,omitempty"`
	Messages    []anthropicMessage `json:"messages"`
	Stream      bool               `json:"stream"`
}

type anthropicMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type anthropicResponse struct {
	Content []struct {
		Text string `json:"text"`
	} `json:"content"`
}

type anthropicStreamEvent struct {
	Type string `json:"type"`
	Delta *struct {
		Text string `json:"text"`
	} `json:"delta,omitempty"`
	ContentBlock *struct {
		Text string `json:"text"`
	} `json:"content_block,omitempty"`
}

func NewAnthropicProvider(apiKey, model string) *AnthropicProvider {
	return &AnthropicProvider{
		apiKey:  apiKey,
		model:   model,
		baseURL: "https://api.anthropic.com/v1",
		client:  &http.Client{},
	}
}

func (p *AnthropicProvider) Name() string {
	return fmt.Sprintf("anthropic-%s", p.model)
}

func (p *AnthropicProvider) GenerateChat(ctx context.Context, messages []ChatMessage, systemPrompt string) (<-chan string, error) {
	apiMessages := make([]anthropicMessage, 0, len(messages))
	for _, msg := range messages {
		role := msg.Role
		if role != "user" && role != "assistant" {
			role = "user"
		}
		apiMessages = append(apiMessages, anthropicMessage{
			Role:    role,
			Content: msg.Content,
		})
	}

	reqBody := anthropicRequest{
		Model:     p.model,
		MaxTokens: 4096,
		Messages:  apiMessages,
		Stream:    true,
	}
	if systemPrompt != "" {
		reqBody.System = systemPrompt
	}

	data, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, p.baseURL+"/messages", bytes.NewReader(data))
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("x-api-key", p.apiKey)
	req.Header.Set("anthropic-version", "2023-06-01")

	resp, err := p.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("send request: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		resp.Body.Close()
		return nil, fmt.Errorf("anthropic API error: %d", resp.StatusCode)
	}

	ch := make(chan string)
	go func() {
		defer resp.Body.Close()
		defer close(ch)

		scanner := bufio.NewScanner(resp.Body)
		for scanner.Scan() {
			line := scanner.Text()

			if !strings.HasPrefix(line, "data: ") {
				continue
			}

			data := strings.TrimPrefix(line, "data: ")
			if data == "[DONE]" {
				continue
			}

			var event anthropicStreamEvent
			if err := json.Unmarshal([]byte(data), &event); err != nil {
				continue
			}

			switch event.Type {
			case "content_block_delta":
				if event.Delta != nil && event.Delta.Text != "" {
					ch <- event.Delta.Text
				}
			case "content_block_start":
				if event.ContentBlock != nil && event.ContentBlock.Text != "" {
					ch <- event.ContentBlock.Text
				}
			}
		}
	}()

	return ch, nil
}

func (p *AnthropicProvider) GenerateEmbedding(ctx context.Context, text string) ([]float64, error) {
	return simpleEmbedding(text), nil
}

func simpleEmbedding(text string) []float64 {
	dim := 256
	emb := make([]float64, dim)
	runes := []rune(text)

	for i, r := range runes {
		idx := i % dim
		emb[idx] += float64(r) / 65536.0
	}

	norm := 0.0
	for _, v := range emb {
		norm += v * v
	}
	if norm > 0 {
		invNorm := 1.0 / sqrt(norm)
		for i := range emb {
			emb[i] *= invNorm
		}
	}

	return emb
}

func sqrt(x float64) float64 {
	if x <= 0 {
		return 0
	}
	z := x / 2.0
	for i := 0; i < 10; i++ {
		z -= (z*z - x) / (2 * z)
	}
	return z
}

func (p *AnthropicProvider) nonStreamingChat(ctx context.Context, messages []anthropicMessage, systemPrompt string) (string, error) {
	reqBody := anthropicRequest{
		Model:     p.model,
		MaxTokens: 4096,
		Messages:  messages,
		Stream:    false,
	}
	if systemPrompt != "" {
		reqBody.System = systemPrompt
	}

	data, err := json.Marshal(reqBody)
	if err != nil {
		return "", err
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, p.baseURL+"/messages", bytes.NewReader(data))
	if err != nil {
		return "", err
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("x-api-key", p.apiKey)
	req.Header.Set("anthropic-version", "2023-06-01")

	resp, err := p.client.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("anthropic API error %d: %s", resp.StatusCode, string(body))
	}

	var result anthropicResponse
	if err := json.Unmarshal(body, &result); err != nil {
		return "", err
	}

	if len(result.Content) > 0 {
		return result.Content[0].Text, nil
	}

	return "", fmt.Errorf("no response from Anthropic")
}
