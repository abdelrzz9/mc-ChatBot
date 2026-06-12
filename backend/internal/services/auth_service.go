package services

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/rs/zerolog/log"
	"golang.org/x/crypto/bcrypt"

	"github.com/mc-club/chatbot-backend/internal/config"
	"github.com/mc-club/chatbot-backend/internal/models"
	"github.com/mc-club/chatbot-backend/internal/repositories"
)

type AuthService struct {
	cfg       *config.Config
	authRepo  *repositories.AuthRepository
	settingsRepo *repositories.SettingsRepository
}

func NewAuthService(cfg *config.Config, authRepo *repositories.AuthRepository, settingsRepo *repositories.SettingsRepository) *AuthService {
	return &AuthService{
		cfg:          cfg,
		authRepo:     authRepo,
		settingsRepo: settingsRepo,
	}
}

type Claims struct {
	UserID string `json:"user_id"`
	jwt.RegisteredClaims
}

func (s *AuthService) Register(ctx context.Context, req *models.RegisterRequest) (*models.TokenResponse, error) {
	existing, err := s.authRepo.GetUserByEmail(ctx, req.Email)
	if err != nil {
		return nil, fmt.Errorf("check existing user: %w", err)
	}
	if existing != nil {
		return nil, errors.New("email already registered")
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, fmt.Errorf("hash password: %w", err)
	}

	user, err := s.authRepo.CreateUser(ctx, req.Email, string(hash), req.DisplayName)
	if err != nil {
		return nil, fmt.Errorf("create user: %w", err)
	}

	if err := s.settingsRepo.CreateSettings(ctx, user.ID); err != nil {
		log.Warn().Err(err).Str("user_id", user.ID).Msg("failed to create default settings")
	}

	return s.generateTokenPair(ctx, user.ID)
}

func (s *AuthService) Login(ctx context.Context, req *models.LoginRequest) (*models.TokenResponse, error) {
	user, err := s.authRepo.GetUserByEmail(ctx, req.Email)
	if err != nil {
		return nil, fmt.Errorf("get user: %w", err)
	}
	if user == nil {
		return nil, errors.New("invalid email or password")
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return nil, errors.New("invalid email or password")
	}

	return s.generateTokenPair(ctx, user.ID)
}

func (s *AuthService) RefreshToken(ctx context.Context, refreshToken string) (*models.TokenResponse, error) {
	tokenHash := hashToken(refreshToken)

	storedToken, err := s.authRepo.GetRefreshToken(ctx, tokenHash)
	if err != nil {
		return nil, fmt.Errorf("get refresh token: %w", err)
	}
	if storedToken == nil {
		return nil, errors.New("invalid refresh token")
	}

	if time.Now().After(storedToken.ExpiresAt) {
		s.authRepo.DeleteRefreshToken(ctx, tokenHash)
		return nil, errors.New("refresh token expired")
	}

	if err := s.authRepo.DeleteRefreshToken(ctx, tokenHash); err != nil {
		log.Warn().Err(err).Msg("failed to delete used refresh token")
	}

	return s.generateTokenPair(ctx, storedToken.UserID)
}

func (s *AuthService) Logout(ctx context.Context, userID, refreshToken string) error {
	if refreshToken != "" {
		tokenHash := hashToken(refreshToken)
		if err := s.authRepo.DeleteRefreshToken(ctx, tokenHash); err != nil {
			log.Warn().Err(err).Msg("failed to delete refresh token on logout")
		}
	}

	if err := s.authRepo.DeleteUserRefreshTokens(ctx, userID); err != nil {
		log.Warn().Err(err).Msg("failed to delete all user refresh tokens")
	}

	return nil
}

func (s *AuthService) ValidateAccessToken(tokenString string) (*Claims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (any, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(s.cfg.JWTSecret), nil
	})
	if err != nil {
		return nil, fmt.Errorf("parse token: %w", err)
	}

	claims, ok := token.Claims.(*Claims)
	if !ok || !token.Valid {
		return nil, errors.New("invalid token")
	}

	return claims, nil
}

func (s *AuthService) generateTokenPair(ctx context.Context, userID string) (*models.TokenResponse, error) {
	now := time.Now()

	accessClaims := &Claims{
		UserID: userID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(s.cfg.JWTAccessExpiry)),
			IssuedAt:  jwt.NewNumericDate(now),
			ID:        uuid.New().String(),
		},
	}

	accessToken := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
	accessStr, err := accessToken.SignedString([]byte(s.cfg.JWTSecret))
	if err != nil {
		return nil, fmt.Errorf("sign access token: %w", err)
	}

	refreshRaw := uuid.New().String()
	refreshHash := hashToken(refreshRaw)

	refreshClaims := &Claims{
		UserID: userID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(s.cfg.JWTRefreshExpiry)),
			IssuedAt:  jwt.NewNumericDate(now),
			ID:        uuid.New().String(),
		},
	}

	refreshToken := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)
	refreshStr, err := refreshToken.SignedString([]byte(s.cfg.JWTSecret))
	if err != nil {
		return nil, fmt.Errorf("sign refresh token: %w", err)
	}

	if err := s.authRepo.SaveRefreshToken(ctx, userID, refreshHash, now.Add(s.cfg.JWTRefreshExpiry)); err != nil {
		return nil, fmt.Errorf("save refresh token: %w", err)
	}

	return &models.TokenResponse{
		AccessToken:  accessStr,
		RefreshToken: refreshStr,
		ExpiresIn:    int64(s.cfg.JWTAccessExpiry.Seconds()),
	}, nil
}

func hashToken(token string) string {
	h := sha256.Sum256([]byte(token))
	return hex.EncodeToString(h[:])
}
