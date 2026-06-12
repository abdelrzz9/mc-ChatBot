package config

import (
	"os"
	"strconv"
	"strings"
)

type Config struct {
	GeminiAPIKey    string
	GeminiModel     string
	Host            string
	Port            string
	CORSOrigins     []string
	MaxUploadSizeMB int64
	ChunkSize       int
	ChunkOverlap    int
	DataDir         string
}

func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}

func getEnvInt(key string, fallback int) int {
	if val := os.Getenv(key); val != "" {
		if i, err := strconv.Atoi(val); err == nil {
			return i
		}
	}
	return fallback
}

func getEnvInt64(key string, fallback int64) int64 {
	if val := os.Getenv(key); val != "" {
		if i, err := strconv.ParseInt(val, 10, 64); err == nil {
			return i
		}
	}
	return fallback
}

func Load() *Config {
	corsRaw := getEnv("CORS_ORIGINS", "*")
	corsOrigins := strings.Split(corsRaw, ",")

	return &Config{
		GeminiAPIKey:    getEnv("GEMINI_API_KEY", ""),
		GeminiModel:     getEnv("GEMINI_MODEL", "gemini-2.0-flash"),
		Host:            getEnv("HOST", "0.0.0.0"),
		Port:            getEnv("PORT", "8080"),
		CORSOrigins:     corsOrigins,
		MaxUploadSizeMB: getEnvInt64("MAX_UPLOAD_SIZE_MB", 20),
		ChunkSize:       getEnvInt("CHUNK_SIZE", 500),
		ChunkOverlap:    getEnvInt("CHUNK_OVERLAP", 50),
		DataDir:         getEnv("DATA_DIR", "./data"),
	}
}
