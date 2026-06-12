package routes

import (
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/redis/go-redis/v9"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"

	"github.com/mc-club/chatbot-backend/internal/ai"
	"github.com/mc-club/chatbot-backend/internal/config"
	"github.com/mc-club/chatbot-backend/internal/handlers"
	"github.com/mc-club/chatbot-backend/internal/middleware"
	"github.com/mc-club/chatbot-backend/internal/repositories"
	"github.com/mc-club/chatbot-backend/internal/services"
)

// @title ChatBot API
// @version 1.0
// @description AI ChatBot with RAG support
// @host localhost:8080
// @BasePath /api/v1
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.
func Setup(cfg *config.Config, pool *pgxpool.Pool, rdb *redis.Client) *gin.Engine {
	gin.SetMode(gin.ReleaseMode)
	router := gin.New()

	router.Use(
		middleware.LoggerMiddleware(),
		gin.Recovery(),
		middleware.CORSMiddleware(cfg.CORSOrigins),
	)

	ratelimiter := middleware.NewRateLimiter(cfg.RateLimitRequests, cfg.RateLimitWindow)
	ratelimiter.Cleanup(cfg.RateLimitWindow * 2)

	authRepo := repositories.NewAuthRepository(pool)
	chatRepo := repositories.NewChatRepository(pool)
	docRepo := repositories.NewDocumentRepository(pool)
	settingsRepo := repositories.NewSettingsRepository(pool)

	ragSvc := services.NewRAGService(cfg, docRepo)

	chatSvc := services.NewChatService(chatRepo, ragSvc)
	authSvc := services.NewAuthService(cfg, authRepo, settingsRepo)
	docSvc := services.NewDocumentService(cfg, docRepo, ragSvc)
	settingsSvc := services.NewSettingsService(settingsRepo)

	defaultProvider := ai.NewProvider(cfg)

	authHandler := handlers.NewAuthHandler(authSvc)
	chatHandler := handlers.NewChatHandler(chatSvc, ragSvc, defaultProvider, settingsSvc)
	docHandler := handlers.NewDocumentHandler(docSvc)
	settingsHandler := handlers.NewSettingsHandler(settingsSvc)

	api := router.Group("/api/v1")
	api.Use(middleware.RateLimitMiddleware(ratelimiter))

	auth := api.Group("/auth")
	{
		auth.POST("/register", authHandler.Register)
		auth.POST("/login", authHandler.Login)
		auth.POST("/refresh", authHandler.Refresh)
	}

	protected := api.Group("")
	protected.Use(middleware.AuthMiddleware(authSvc))
	{
		protected.POST("/auth/logout", authHandler.Logout)

		protected.GET("/conversations", chatHandler.ListConversations)
		protected.POST("/conversations", chatHandler.CreateConversation)
		protected.PUT("/conversations/:id", chatHandler.RenameConversation)
		protected.DELETE("/conversations/:id", chatHandler.DeleteConversation)
		protected.GET("/conversations/:id/messages", chatHandler.GetMessages)
		protected.POST("/chat/send", chatHandler.SendMessage)

		protected.POST("/documents/upload", docHandler.Upload)
		protected.GET("/documents", docHandler.ListDocuments)
		protected.DELETE("/documents/:id", docHandler.DeleteDocument)
		protected.POST("/documents/:id/reindex", docHandler.ReindexDocument)

		protected.GET("/settings", settingsHandler.GetSettings)
		protected.PUT("/settings", settingsHandler.UpdateSettings)
	}

	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	return router
}
