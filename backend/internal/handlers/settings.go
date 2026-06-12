package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/mc-club/chatbot-backend/internal/models"
	"github.com/mc-club/chatbot-backend/internal/services"
)

type SettingsHandler struct {
	settingsService *services.SettingsService
}

func NewSettingsHandler(settingsService *services.SettingsService) *SettingsHandler {
	return &SettingsHandler{settingsService: settingsService}
}

// GetSettings returns user settings
// @Summary Get user settings
// @Tags settings
// @Security BearerAuth
// @Produce json
// @Success 200 {object} models.Settings
// @Failure 401 {object} map[string]string
// @Router /api/v1/settings [get]
func (h *SettingsHandler) GetSettings(c *gin.Context) {
	userID, _ := c.Get("user_id")

	settings, err := h.settingsService.GetSettings(c.Request.Context(), userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	if settings == nil {
		c.JSON(http.StatusOK, gin.H{"settings": nil})
		return
	}

	c.JSON(http.StatusOK, settings)
}

// UpdateSettings updates user settings
// @Summary Update user settings
// @Tags settings
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param request body models.UpdateSettingsRequest true "Settings to update"
// @Success 200 {object} map[string]string
// @Failure 400 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Router /api/v1/settings [put]
func (h *SettingsHandler) UpdateSettings(c *gin.Context) {
	userID, _ := c.Get("user_id")

	var req models.UpdateSettingsRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.settingsService.UpdateSettings(c.Request.Context(), userID.(string), &req); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "settings updated"})
}
