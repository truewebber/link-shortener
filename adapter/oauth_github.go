package adapter

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strconv"

	"github.com/truewebber/gopkg/log"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/github"

	"github.com/truewebber/link-shortener/domain/user"
)

type gitHubOAuthProvider struct {
	config     *oauth2.Config
	logger     log.Logger
	httpClient *http.Client
}

func NewGitHubOAuthProvider(
	clientID, clientSecret, redirectURL string,
	logger log.Logger,
) user.OAuthProvider {
	config := &oauth2.Config{
		ClientID:     clientID,
		ClientSecret: clientSecret,
		RedirectURL:  redirectURL,
		Scopes:       []string{"user:email", "read:user"},
		Endpoint:     github.Endpoint,
	}

	return &gitHubOAuthProvider{
		config:     config,
		logger:     logger,
		httpClient: &http.Client{},
	}
}

func (p *gitHubOAuthProvider) GetAuthURL(state string) (string, error) {
	return p.config.AuthCodeURL(state), nil
}

func (p *gitHubOAuthProvider) ExchangeCode(ctx context.Context, code string) (*user.OAuthInfo, error) {
	token, err := p.config.Exchange(ctx, code)
	if err != nil {
		return nil, fmt.Errorf("exchange code: %w", err)
	}

	return p.GetUserInfo(ctx, token.AccessToken)
}

type githubUserInfoResponse struct {
	Email     string `json:"email"`
	Name      string `json:"name"`
	Login     string `json:"login"`
	AvatarURL string `json:"avatar_url"`
	ID        int    `json:"id"`
}

const githubAPIUser = "https://api.github.com/user"

func (p *gitHubOAuthProvider) GetUserInfo(ctx context.Context, accessToken string) (*user.OAuthInfo, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, githubAPIUser, http.NoBody)
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}

	req.Header.Add("Authorization", "token "+accessToken)
	req.Header.Add("Accept", "application/vnd.github.v3+json")

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
		return nil, fmt.Errorf("read body all: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("%w %d, body: %s", errNonOKStatusCode, resp.StatusCode, string(body))
	}

	userInfo := &githubUserInfoResponse{}

	if unmarshalErr := json.Unmarshal(body, userInfo); unmarshalErr != nil {
		return nil, fmt.Errorf("unmarshal user info: %w", unmarshalErr)
	}

	email, err := p.pickUpEmail(ctx, accessToken, userInfo.Email)
	if err != nil {
		return nil, fmt.Errorf("pick up email: %w", err)
	}

	return &user.OAuthInfo{
		ProviderID: strconv.Itoa(userInfo.ID),
		Provider:   user.ProviderGithub,
		Email:      email,
		Name:       p.pickUpName(userInfo.Name, userInfo.Login),
		AvatarURL:  userInfo.AvatarURL,
	}, nil
}

func (p *gitHubOAuthProvider) pickUpEmail(
	ctx context.Context, accessToken string, email string,
) (string, error) {
	if email != "" {
		return email, nil
	}

	primaryEmail, err := p.getPrimaryEmail(ctx, accessToken)
	if err != nil {
		return "", fmt.Errorf("get primary email: %w", err)
	}

	return primaryEmail, nil
}

func (p *gitHubOAuthProvider) pickUpName(name, nickname string) string {
	if name != "" {
		return name
	}

	return nickname
}

type githubEmail struct {
	Email    string `json:"email"`
	Primary  bool   `json:"primary"`
	Verified bool   `json:"verified"`
}

var errNonOKStatusCode = errors.New("non ok status code")

const githubAPIUserEmail = "https://api.github.com/user/emails"

func (p *gitHubOAuthProvider) getPrimaryEmail(ctx context.Context, accessToken string) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, githubAPIUserEmail, http.NoBody)
	if err != nil {
		return "", fmt.Errorf("create request: %w", err)
	}

	req.Header.Add("Authorization", "token "+accessToken)
	req.Header.Add("Accept", "application/vnd.github.v3+json")

	resp, err := p.httpClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("do request: %w", err)
	}

	defer func() {
		if closeErr := resp.Body.Close(); closeErr != nil {
			p.logger.Error("failed to close response body", "err", closeErr)
		}
	}()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("read body: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("%w %d, body: %s", errNonOKStatusCode, resp.StatusCode, string(body))
	}

	var emails []githubEmail

	if unmarshalErr := json.Unmarshal(body, &emails); unmarshalErr != nil {
		return "", fmt.Errorf("unmarshal emails: %w", unmarshalErr)
	}

	email, err := p.pickUpPrimaryEmail(emails)
	if err != nil {
		return "", fmt.Errorf("pick up email: %w", err)
	}

	return email, nil
}

var errVerifiedEmailNotFound = errors.New("no verified email found")

func (p *gitHubOAuthProvider) pickUpPrimaryEmail(emails []githubEmail) (string, error) {
	for _, email := range emails {
		if email.Primary && email.Verified {
			return email.Email, nil
		}
	}

	for _, email := range emails {
		if email.Verified {
			return email.Email, nil
		}
	}

	return "", errVerifiedEmailNotFound
}
