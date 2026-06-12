package services

import (
	"context"
	"fmt"

	"github.com/mc-club/chatbot-backend/internal/models"
	"github.com/mc-club/chatbot-backend/internal/repositories"
)

type SettingsService struct {
	settingsRepo *repositories.SettingsRepository
}

func NewSettingsService(settingsRepo *repositories.SettingsRepository) *SettingsService {
	return &SettingsService{settingsRepo: settingsRepo}
}

func (s *SettingsService) GetSettings(ctx context.Context, userID string) (*models.Settings, error) {
	settings, err := s.settingsRepo.GetSettings(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("get settings: %w", err)
	}
	if settings == nil {
		if err := s.settingsRepo.CreateSettings(ctx, userID); err != nil {
			return nil, fmt.Errorf("create default settings: %w", err)
		}
		return s.settingsRepo.GetSettings(ctx, userID)
	}
	return settings, nil
}

func (s *SettingsService) UpdateSettings(ctx context.Context, userID string, req *models.UpdateSettingsRequest) error {
	settings, err := s.settingsRepo.GetSettings(ctx, userID)
	if err != nil {
		return fmt.Errorf("get settings: %w", err)
	}
	if settings == nil {
		if err := s.settingsRepo.CreateSettings(ctx, userID); err != nil {
			return fmt.Errorf("create settings: %w", err)
		}
	}

	return s.settingsRepo.UpdateSettings(ctx, userID, req)
}
