package handler

import (
	"crypto/rand"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"

	"github.com/gorilla/mux"
	"github.com/truewebber/gopkg/log"

	"github.com/truewebber/link-shortener/app"
	"github.com/truewebber/link-shortener/app/command"
	apperrors "github.com/truewebber/link-shortener/app/errors"
	apptypes "github.com/truewebber/link-shortener/app/types"
	"github.com/truewebber/link-shortener/port/httprest/context"
)

type AuthHandler struct {
	app          *app.APIApp
	logger       log.Logger
	cookieDomain string
}

func NewAuthHandler(
	app *app.APIApp,
	cookieDomain string,
	logger log.Logger,
) *AuthHandler {
	return &AuthHandler{
		app:          app,
		logger:       logger,
		cookieDomain: cookieDomain,
	}
}

type authResponse struct {
	User                *userInfo `json:"user"`
	AccessToken         string    `json:"access_token"`
	RefreshToken        string    `json:"refresh_token"`
	AccessTokenExpiryMS int64     `json:"access_token_expiry_ms"`
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

func (h *AuthHandler) StartOAuth(w http.ResponseWriter, r *http.Request) {
	pathVars := mux.Vars(r)

	provider, err := h.buildToUseCaseProvider(pathVars["provider"])
	if err != nil {
		http.Error(w, "invalid provider", http.StatusBadRequest)

		return
	}

	state := h.generateState()

	response, err := h.app.Query.GetAuthURL.Handle(r.Context(), provider, state)
	if err != nil {
		h.logger.Error("failed to get auth url", "provider", provider, "error", err)

		http.Error(w, "internal", http.StatusInternalServerError)

		return
	}

	cookie := h.buildStateCooke(state)
	http.SetCookie(w, cookie)

	http.Redirect(w, r, response.URL, http.StatusFound)
}

const stateBytesLen = 32

func (h *AuthHandler) generateState() string {
	b := make([]byte, stateBytesLen)
	//nolint:errcheck // redundant check, rand.Read panic on err inside
	rand.Read(b)

	return base64.StdEncoding.EncodeToString(b)
}

const (
	stateCookieName   = "oauth_state"
	stateCookieMaxAge = 300
)

func (h *AuthHandler) buildStateCooke(state string) *http.Cookie {
	return &http.Cookie{
		Name:     stateCookieName,
		Value:    state,
		Path:     "/",
		Secure:   true,
		HttpOnly: true,
		SameSite: http.SameSiteNoneMode,
		Domain:   h.cookieDomain,
		MaxAge:   stateCookieMaxAge,
	}
}

func (h *AuthHandler) validateState(r *http.Request, state string) bool {
	cookie, err := r.Cookie(stateCookieName)
	if err != nil {
		return false
	}

	return cookie.Value == state
}

func (h *AuthHandler) OAuthCallback(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		redirectURL := h.buildRedirectErrorURL("invalid request")
		http.Redirect(w, r, redirectURL, http.StatusFound)

		return
	}

	state := r.FormValue("state")
	if !h.validateState(r, state) {
		redirectURL := h.buildRedirectErrorURL("invalid state")
		http.Redirect(w, r, redirectURL, http.StatusFound)

		return
	}

	pathVars := mux.Vars(r)

	provider, err := h.buildToUseCaseProvider(pathVars["provider"])
	if err != nil {
		redirectURL := h.buildRedirectErrorURL("invalid request")
		http.Redirect(w, r, redirectURL, http.StatusFound)

		return
	}

	code := r.FormValue("code")
	userData := r.FormValue("user")
	errorMsg := r.FormValue("error")

	params := command.FinishOAuthParams{
		Provider:     provider,
		Code:         code,
		ErrorMessage: errorMsg,
		UserData:     []byte(userData),
	}

	oauthInfo, err := h.app.Command.FinishOAuth.Handle(r.Context(), params)
	if err != nil {
		h.logger.Error("failed handle FinishOAuth", "params", params, "error", err)

		redirectURL := h.buildRedirectErrorURL("unknown error")
		http.Redirect(w, r, redirectURL, http.StatusFound)

		return
	}

	redirectURL := h.buildRedirectSuccessURL(oauthInfo.Token.AccessToken)
	http.Redirect(w, r, redirectURL, http.StatusFound)
}

func (h *AuthHandler) buildRedirectSuccessURL(accessToken string) string {
	query := url.Values{}
	query.Add("access_token", accessToken)

	redirectURL := url.URL{
		Path: "/app/auth/success",
	}

	redirectURL.RawQuery = query.Encode()

	return redirectURL.String()
}

func (h *AuthHandler) buildRedirectErrorURL(errorMessage string) string {
	query := url.Values{}
	query.Add("error", errorMessage)

	redirectURL := url.URL{
		Path: "/app/auth/fail",
	}

	redirectURL.RawQuery = query.Encode()

	return redirectURL.String()
}

func (h *AuthHandler) RefreshToken(w http.ResponseWriter, r *http.Request) {
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

func (h *AuthHandler) Logout(w http.ResponseWriter, r *http.Request) {
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

func (h *AuthHandler) Me(w http.ResponseWriter, r *http.Request) {
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
		AccessToken:         auth.Token.AccessToken,
		AccessTokenExpiryMS: auth.Token.AccessTokenExpiresAt.UnixMilli(),
		RefreshToken:        auth.Token.RefreshToken,
		User:                user,
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
