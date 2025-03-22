package adapter

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"github.com/truewebber/gopkg/log"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"

	"github.com/truewebber/link-shortener/domain/user"
)

type googleOAuthProvider struct {
	config     *oauth2.Config
	httpClient *http.Client
	logger     log.Logger
}

func NewGoogleOAuthProvider(clientID, clientSecret, redirectURL string, logger log.Logger) user.OAuthProvider {
	config := &oauth2.Config{
		ClientID:     clientID,
		ClientSecret: clientSecret,
		RedirectURL:  redirectURL,
		Scopes: []string{
			"https://www.googleapis.com/auth/userinfo.email",
			"https://www.googleapis.com/auth/userinfo.profile",
		},
		Endpoint: google.Endpoint,
	}

	return &googleOAuthProvider{
		config:     config,
		httpClient: &http.Client{},
		logger:     logger,
	}
}

func (p *googleOAuthProvider) GetAuthURL(state string) (string, error) {
	return p.config.AuthCodeURL(state), nil
}

func (p *googleOAuthProvider) ExchangeCode(ctx context.Context, code string) (*user.OAuthInfo, error) {
	token, err := p.config.Exchange(ctx, code)
	if err != nil {
		return nil, fmt.Errorf("exchange code: %w", err)
	}

	userInfo, err := p.getUserInfo(ctx, token.AccessToken)
	if err != nil {
		return nil, fmt.Errorf("get user info: %w", err)
	}

	return userInfo, nil
}

type googleUserInfo struct {
	Sub     string `json:"sub"`
	Email   string `json:"email"`
	Name    string `json:"name"`
	Picture string `json:"picture"`
}

const googleAPIUserInfo = "https://www.googleapis.com/oauth2/v3/userinfo"

func (p *googleOAuthProvider) getUserInfo(ctx context.Context, accessToken string) (*user.OAuthInfo, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, googleAPIUserInfo, http.NoBody)
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}

	req.Header.Add("Authorization", "Bearer "+accessToken)

	resp, err := p.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("do request: %w", err)
	}

	defer func() {
		if closeErr := resp.Body.Close(); closeErr != nil {
			p.logger.Error("failed to close response body", "err", closeErr)
		}
	}()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read body: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("%w %d, body: %s", errNonOKStatusCode, resp.StatusCode, string(body))
	}

	userInfo := &googleUserInfo{}

	if err := json.Unmarshal(body, userInfo); err != nil {
		return nil, fmt.Errorf("unmarshal user info: %w", err)
	}

	return &user.OAuthInfo{
		Provider:   user.ProviderGoogle,
		ProviderID: userInfo.Sub,
		Email:      userInfo.Email,
		Name:       userInfo.Name,
		AvatarURL:  userInfo.Picture,
	}, nil
}
