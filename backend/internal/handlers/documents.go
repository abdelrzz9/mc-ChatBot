package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"

	"github.com/mc-club/chatbot-backend/internal/services"
)

type DocumentHandler struct {
	docService *services.DocumentService
}

func NewDocumentHandler(docService *services.DocumentService) *DocumentHandler {
	return &DocumentHandler{docService: docService}
}

// Upload handles file upload
// @Summary Upload a document
// @Tags documents
// @Security BearerAuth
// @Accept multipart/form-data
// @Produce json
// @Param file formData file true "File to upload"
// @Success 201 {object} models.Document
// @Failure 400 {object} map[string]string
// @Failure 413 {object} map[string]string
// @Router /api/v1/documents/upload [post]
func (h *DocumentHandler) Upload(c *gin.Context) {
	userID, _ := c.Get("user_id")

	file, header, err := c.Request.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "no file provided"})
		return
	}
	defer file.Close()

	contentType := header.Header.Get("Content-Type")
	if contentType == "" {
		contentType = "application/octet-stream"
	}

	doc, err := h.docService.Upload(c.Request.Context(), userID.(string), header.Filename, contentType, file)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, doc)
}

// ListDocuments returns all documents for the user
// @Summary List documents
// @Tags documents
// @Security BearerAuth
// @Produce json
// @Success 200 {array} models.Document
// @Failure 401 {object} map[string]string
// @Router /api/v1/documents [get]
func (h *DocumentHandler) ListDocuments(c *gin.Context) {
	userID, _ := c.Get("user_id")

	docs, err := h.docService.ListDocuments(c.Request.Context(), userID.(string))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"documents": docs})
}

// DeleteDocument deletes a document
// @Summary Delete a document
// @Tags documents
// @Security BearerAuth
// @Produce json
// @Param id path string true "Document ID"
// @Success 200 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Router /api/v1/documents/{id} [delete]
func (h *DocumentHandler) DeleteDocument(c *gin.Context) {
	userID, _ := c.Get("user_id")
	id := c.Param("id")

	if err := h.docService.DeleteDocument(c.Request.Context(), userID.(string), id); err != nil {
		if err.Error() == "document not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "document deleted"})
}

// ReindexDocument re-indexes a document
// @Summary Re-index a document
// @Tags documents
// @Security BearerAuth
// @Produce json
// @Param id path string true "Document ID"
// @Success 200 {object} map[string]string
// @Failure 401 {object} map[string]string
// @Failure 404 {object} map[string]string
// @Router /api/v1/documents/{id}/reindex [post]
func (h *DocumentHandler) ReindexDocument(c *gin.Context) {
	userID, _ := c.Get("user_id")
	id := c.Param("id")

	if err := h.docService.Reindex(c.Request.Context(), userID.(string), id); err != nil {
		if err.Error() == "document not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "document reindexed"})
}
