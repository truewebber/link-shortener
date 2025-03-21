package handler

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/truewebber/gopkg/log"

	"github.com/truewebber/link-shortener/app"
	"github.com/truewebber/link-shortener/app/command"
	apperrors "github.com/truewebber/link-shortener/app/errors"
	apptypes "github.com/truewebber/link-shortener/app/types"
)

type AuthHandler struct {
	app    *app.APIApp
	logger log.Logger
}

func NewAuthHandler(app *app.APIApp, logger log.Logger) *AuthHandler {
	return &AuthHandler{
		app:    app,
		logger: logger,
	}
}

type oauthRequest struct {
	ProviderType string `json:"provider"`
	ProviderID   string `json:"provider_id"`
	Email        string `json:"email"`
	Name         string `json:"name"`
	AvatarURL    string `json:"avatar_url,omitempty"`
}

type authResponse struct {
	User         *userInfo `json:"user"`
	AccessToken  string    `json:"access_token"`
	RefreshToken string    `json:"refresh_token"`
}

type userInfo struct {
	Name      string `json:"name"`
	Email     string `json:"email"`
	AvatarURL string `json:"avatar_url,omitempty"`
	Provider  string `json:"provider"`
	ID        uint64 `json:"id"`
}

type refreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

func (h *AuthHandler) HandleOAuth(w http.ResponseWriter, r *http.Request) {
	var req oauthRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if req.ProviderType == "" || req.ProviderID == "" || req.Email == "" || req.Name == "" {
		http.Error(w, "Missing required fields", http.StatusBadRequest)
		return
	}

	// TODO: separate in a function
	var providerType apptypes.Provider
	switch req.ProviderType {
	case "google":
		providerType = apptypes.ProviderGoogle
	case "apple":
		providerType = apptypes.ProviderApple
	case "github":
		providerType = apptypes.ProviderGithub
	default:
		http.Error(w, "Invalid provider type", http.StatusBadRequest)
		return
	}

	params := command.SignUpParams{
		Provider:   providerType,
		ProviderID: req.ProviderID,
		Email:      req.Email,
		Name:       req.Name,
		AvatarURL:  req.AvatarURL,
	}

	result, err := h.app.Command.SignUp.Handle(r.Context(), params)
	if err != nil {
		h.logger.Error("Failed OAuth authentication", "params", params, "error", err)
		http.Error(w, "Authentication failed", http.StatusInternalServerError)
		return
	}

	response := authResponse{
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
		User: &userInfo{
			ID:        result.User.ID,
			Name:      result.User.Name,
			Email:     result.User.Email,
			AvatarURL: result.User.AvatarURL,
			// TODO: use result.User.Provider instead
			//   cast it in a separate cat provider function
			Provider: req.ProviderType,
		},
	}

	w.Header().Set("Content-Type", "application/json")

	if err := json.NewEncoder(w).Encode(response); err != nil {
		h.logger.Error("Failed to json encode response", "response", response, "error", err)
		http.Error(w, "internal", http.StatusInternalServerError)
		return
	}
}

func (h *AuthHandler) HandleRefreshToken(w http.ResponseWriter, r *http.Request) {
	var req refreshRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	if req.RefreshToken == "" {
		http.Error(w, "Refresh token is required", http.StatusBadRequest)
		return
	}

	result, err := h.app.Command.RefreshToken.Handle(r.Context(), req.RefreshToken)
	if errors.Is(err, apperrors.ErrInvalidCredentials) || errors.Is(err, apperrors.ErrTokenExpired) {
		http.Error(w, "Invalid or expired refresh token", http.StatusUnauthorized)
		return
	}

	if err != nil {
		h.logger.Error("Failed to refresh token", "request", req, "error", err)
		http.Error(w, "internal", http.StatusInternalServerError)
		return
	}

	// TODO: separate in a function
	providerStr := "unknown"
	switch result.User.Provider {
	case apptypes.ProviderGoogle:
		providerStr = "google"
	case apptypes.ProviderApple:
		providerStr = "apple"
	case apptypes.ProviderGithub:
		providerStr = "github"
	}

	response := authResponse{
		AccessToken:  result.AccessToken,
		RefreshToken: result.RefreshToken,
		User: &userInfo{
			ID:        result.User.ID,
			Name:      result.User.Name,
			Email:     result.User.Email,
			AvatarURL: result.User.AvatarURL,
			Provider:  providerStr,
		},
	}

	w.Header().Set("Content-Type", "application/json")

	if err := json.NewEncoder(w).Encode(response); err != nil {
		h.logger.Error("Failed to json encode response", "response", response, "error", err)
		http.Error(w, "internal", http.StatusInternalServerError)
		return
	}
}

const contextKeyToken = "access_token"

func (h *AuthHandler) HandleLogout(w http.ResponseWriter, r *http.Request) {
	accessToken, ok := r.Context().Value(contextKeyToken).(string)
	if !ok {
		http.Error(w, "Authorization token required", http.StatusUnauthorized)
		return
	}

	if err := h.app.Command.Logout.Handle(r.Context(), accessToken); err != nil {
		h.logger.Error("Failed to logout", "accessToken", accessToken, "error", err)
		http.Error(w, "internal", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}

const contextKeyUser = "user"

func (h *AuthHandler) HandleMe(w http.ResponseWriter, r *http.Request) {
	user, ok := r.Context().Value(contextKeyUser).(*apptypes.User)
	if !ok {
		http.Error(w, "Authentication required", http.StatusUnauthorized)
		return
	}

	// TODO: separate in a function, create a new Provider type for a port layer!
	providerStr := "unknown"
	switch user.Provider {
	case apptypes.ProviderGoogle:
		providerStr = "google"
	case apptypes.ProviderApple:
		providerStr = "apple"
	case apptypes.ProviderGithub:
		providerStr = "github"
	case apptypes.ProviderAnonymous:
		providerStr = "anonymous"
	}

	response := userInfo{
		ID:        user.ID,
		Name:      user.Name,
		Email:     user.Email,
		AvatarURL: user.AvatarURL,
		Provider:  providerStr,
	}

	w.Header().Set("Content-Type", "application/json")

	if err := json.NewEncoder(w).Encode(response); err != nil {
		h.logger.Error("Failed to json encode response", "response", response, "error", err)
		http.Error(w, "internal", http.StatusInternalServerError)
		return
	}
}
