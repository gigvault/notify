package api

import (
	"encoding/json"
	"net/http"

	"github.com/gigvault/shared/pkg/logger"
	"github.com/gorilla/mux"
	"go.uber.org/zap"
)

type HTTPHandler struct {
	logger *logger.Logger
}

func NewHTTPHandler(logger *logger.Logger) *HTTPHandler {
	return &HTTPHandler{logger: logger}
}

func (h *HTTPHandler) Routes() http.Handler {
	r := mux.NewRouter()
	r.HandleFunc("/health", h.Health).Methods("GET")
	r.HandleFunc("/ready", h.Ready).Methods("GET")
	
	api := r.PathPrefix("/api/v1").Subrouter()
	api.HandleFunc("/status", h.Status).Methods("GET")
	
	return h.loggingMiddleware(r)
}

func (h *HTTPHandler) Health(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "healthy"})
}

func (h *HTTPHandler) Ready(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"status": "ready"})
}

func (h *HTTPHandler) Status(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"service": "notify",
		"status":  "running",
	})
}

func (h *HTTPHandler) loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		h.logger.Info("HTTP request",
			zap.String("method", r.Method),
			zap.String("path", r.URL.Path),
		)
		next.ServeHTTP(w, r)
	})
}
