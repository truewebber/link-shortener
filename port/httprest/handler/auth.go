package handler

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"

	"github.com/truewebber/gopkg/log"

	"github.com/truewebber/link-shortener/app"
	"github.com/truewebber/link-shortener/app/command"
	apperrors "github.com/truewebber/link-shortener/app/errors"
	apptypes "github.com/truewebber/link-shortener/app/types"
	"github.com/truewebber/link-shortener/port/httprest/context"
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
	Provider   string `json:"provider"`
	ProviderID string `json:"provider_id"`
	Email      string `json:"email"`
	Name       string `json:"name"`
	AvatarURL  string `json:"avatar_url,omitempty"`
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
		http.Error(w, "invalid request body", http.StatusBadRequest)

		return
	}

	provider, err := h.buildToUseCaseProvider(req.Provider)
	if err != nil {
		http.Error(w, "invalid provider", http.StatusBadRequest)

		return
	}

	params := command.SignUpParams{
		Provider:   provider,
		ProviderID: req.ProviderID,
		Email:      req.Email,
		Name:       req.Name,
		AvatarURL:  req.AvatarURL,
	}

	auth, err := h.app.Command.SignUp.Handle(r.Context(), params)
	if err != nil {
		h.logger.Error("failed handle SignUp", "params", params, "error", err)

		http.Error(w, "authentication failed", http.StatusInternalServerError)

		return
	}

	response, err := h.buildAuthResponse(auth)
	if err != nil {
		h.logger.Error("failed build auth response", "auth_data", auth, "params", params, "error", err)

		http.Error(w, "internal", http.StatusInternalServerError)

		return
	}

	w.Header().Set("Content-Type", "application/json")

	if err := json.NewEncoder(w).Encode(response); err != nil {
		h.logger.Error("Failed to json encode response",
			"response", response, "params", params, "error", err,
		)

		http.Error(w, "internal", http.StatusInternalServerError)

		return
	}
}

func (h *AuthHandler) HandleRefreshToken(w http.ResponseWriter, r *http.Request) {
	var req refreshRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)

		return
	}

	if req.RefreshToken == "" {
		http.Error(w, "refresh token is required", http.StatusBadRequest)

		return
	}

	auth, err := h.app.Command.RefreshToken.Handle(r.Context(), req.RefreshToken)
	if errors.Is(err, apperrors.ErrInvalidCredentials) ||
		errors.Is(err, apperrors.ErrTokenExpired) ||
		errors.Is(err, apperrors.ErrUserNotFound) {
		http.Error(w, "invalid or expired refresh token", http.StatusUnauthorized)

		return
	}

	if err != nil {
		h.logger.Error("failed to refresh token", "request", req, "error", err)

		http.Error(w, "internal", http.StatusInternalServerError)

		return
	}

	response, err := h.buildAuthResponse(auth)
	if err != nil {
		h.logger.Error("failed build auth response", "auth_data", auth, "error", err)

		http.Error(w, "internal", http.StatusInternalServerError)

		return
	}

	w.Header().Set("Content-Type", "application/json")

	if err := json.NewEncoder(w).Encode(response); err != nil {
		h.logger.Error("failed to json encode response", "response", response, "error", err)

		http.Error(w, "internal", http.StatusInternalServerError)

		return
	}
}

func (h *AuthHandler) HandleLogout(w http.ResponseWriter, r *http.Request) {
	accessToken, ok := r.Context().Value(context.KeyToken).(string)
	if !ok {
		http.Error(w, "authorization token required", http.StatusUnauthorized)

		return
	}

	user, ok := r.Context().Value(context.KeyUser).(*apptypes.User)
	if !ok {
		http.Error(w, "authorization required", http.StatusUnauthorized)

		return
	}

	if err := h.app.Command.Logout.Handle(r.Context(), accessToken); err != nil {
		h.logger.Error("failed to logout", "accessToken", accessToken, "user", user, "error", err)

		http.Error(w, "internal", http.StatusInternalServerError)

		return
	}

	w.WriteHeader(http.StatusNoContent)
}

func (h *AuthHandler) HandleMe(w http.ResponseWriter, r *http.Request) {
	user, ok := r.Context().Value(context.KeyUser).(*apptypes.User)
	if !ok {
		http.Error(w, "authentication required", http.StatusUnauthorized)

		return
	}

	builtUser, err := h.buildUserInfo(user)
	if err != nil {
		h.logger.Error("failed build user info response", "user", user, "error", err)

		http.Error(w, "internal", http.StatusInternalServerError)

		return
	}

	w.Header().Set("Content-Type", "application/json")

	if err := json.NewEncoder(w).Encode(builtUser); err != nil {
		h.logger.Error("failed to json encode response", "response", builtUser, "error", err)

		http.Error(w, "internal", http.StatusInternalServerError)

		return
	}
}

const (
	providerGoogle    = "google"
	providerApple     = "apple"
	providerGithub    = "github"
	providerAnonymous = "anonymous"
)

var errUnsupportedProvider = errors.New("unsupported provider")

func (h *AuthHandler) buildToUseCaseProvider(provider string) (apptypes.Provider, error) {
	switch provider {
	case providerAnonymous:
		return apptypes.ProviderAnonymous, nil
	case providerGoogle:
		return apptypes.ProviderGoogle, nil
	case providerApple:
		return apptypes.ProviderApple, nil
	case providerGithub:
		return apptypes.ProviderGithub, nil
	}

	return 0, errUnsupportedProvider
}

func (h *AuthHandler) buildFromUseCaseProvider(provider apptypes.Provider) (string, error) {
	switch provider {
	case apptypes.ProviderAnonymous:
		return providerAnonymous, nil
	case apptypes.ProviderGoogle:
		return providerGoogle, nil
	case apptypes.ProviderApple:
		return providerApple, nil
	case apptypes.ProviderGithub:
		return providerGithub, nil
	}

	return "", errUnsupportedProvider
}

func (h *AuthHandler) buildAuthResponse(auth *apptypes.Auth) (*authResponse, error) {
	user, err := h.buildUserInfo(auth.User)
	if err != nil {
		return &authResponse{}, fmt.Errorf("build user info: %w", err)
	}

	return &authResponse{
		AccessToken:  auth.AccessToken,
		RefreshToken: auth.RefreshToken,
		User:         user,
	}, nil
}

func (h *AuthHandler) buildUserInfo(user *apptypes.User) (*userInfo, error) {
	responseProvider, err := h.buildFromUseCaseProvider(user.Provider)
	if err != nil {
		return &userInfo{}, fmt.Errorf("build provider from usecase: %w", err)
	}

	return &userInfo{
		ID:        user.ID,
		Name:      user.Name,
		Email:     user.Email,
		AvatarURL: user.AvatarURL,
		Provider:  responseProvider,
	}, nil
}
