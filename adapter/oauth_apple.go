package adapter

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"time"

	"github.com/Timothylock/go-signin-with-apple/apple"
	"github.com/golang-jwt/jwt/v5"
	"github.com/truewebber/gopkg/log"
	"golang.org/x/oauth2"

	"github.com/truewebber/link-shortener/domain/user"
)

type appleOAuthProvider struct {
	logger      log.Logger
	httpClient  *http.Client
	privateKey  string
	clientID    string
	redirectURL string
	teamID      string
	keyID       string
	endpoint    oauth2.Endpoint
	issueCache  issueCache
}

type issueCache struct {
	issuedAt             time.Time
	clientSecret         string
	wasIssuedAtLeastOnce bool
}

func NewAppleOAuthProvider(
	clientID, redirectURL, keyID, teamID, privateKeyPEM string,
	logger log.Logger,
) user.OAuthProvider {
	return &appleOAuthProvider{
		clientID:    clientID,
		redirectURL: redirectURL,
		privateKey:  privateKeyPEM,
		teamID:      teamID,
		keyID:       keyID,
		endpoint: oauth2.Endpoint{
			AuthURL:  "https://appleid.apple.com/auth/authorize",
			TokenURL: "https://appleid.apple.com/auth/token",
		},
		issueCache: issueCache{},
		httpClient: &http.Client{},
		logger:     logger,
	}
}

func (p *appleOAuthProvider) GetAuthURL(state string) (string, error) {
	clientSecret, err := p.getClientSecret()
	if err != nil {
		return "", fmt.Errorf("get client secret: %w", err)
	}

	config := &oauth2.Config{
		ClientID:     p.clientID,
		ClientSecret: clientSecret,
		RedirectURL:  p.redirectURL,
		Scopes:       []string{"name", "email"},
		Endpoint:     p.endpoint,
	}

	return config.AuthCodeURL(state, oauth2.SetAuthURLParam("response_mode", "form_post")), nil
}

var errVerifyWebTokenGotError = errors.New("error verifying WebToken")

func (p *appleOAuthProvider) ExchangeCode(ctx context.Context, code string) (*user.OAuthInfo, error) {
	clientSecret, err := p.getClientSecret()
	if err != nil {
		return nil, fmt.Errorf("get client secret: %w", err)
	}

	client := apple.New()

	req := apple.WebValidationTokenRequest{
		ClientID:     p.clientID,
		ClientSecret: clientSecret,
		Code:         code,
		RedirectURI:  p.redirectURL,
	}

	var resp apple.ValidationResponse

	err = client.VerifyWebToken(ctx, req, &resp)
	if err != nil {
		return nil, fmt.Errorf("verify web token: %w", err)
	}

	if resp.Error != "" {
		return nil, fmt.Errorf("%w: %s", errVerifyWebTokenGotError, resp.Error)
	}

	oauthInfo, err := p.buildOAuthInfoFromToken(resp.IDToken)
	if err != nil {
		return nil, fmt.Errorf("build oauth info: %w", err)
	}

	return oauthInfo, nil
}

func (p *appleOAuthProvider) buildOAuthInfoFromToken(idToken string) (*user.OAuthInfo, error) {
	unique, err := apple.GetUniqueID(idToken)
	if err != nil {
		return nil, fmt.Errorf("get unique id: %w", err)
	}

	claim, err := apple.GetClaims(idToken)
	if err != nil {
		return nil, fmt.Errorf("get claims: %w", err)
	}

	email, err := p.extractEmailFromClaims(claim)
	if err != nil {
		return nil, fmt.Errorf("extract email: %w", err)
	}

	return &user.OAuthInfo{
		Provider:   user.ProviderApple,
		ProviderID: unique,
		Email:      email,
		Name:       "", // Apple doesn't provide name in the token, it comes in user data
		AvatarURL:  "", // Apple doesn't provide avatar
	}, nil
}

var errNoEmailFieldsFound = errors.New("no email fields found")

func (p *appleOAuthProvider) extractEmailFromClaims(claim *jwt.MapClaims) (string, error) {
	isPrivateEmail, ok := (*claim)["is_private_email"].(string)
	if ok {
		return isPrivateEmail, nil
	}

	emailVerified, ok := (*claim)["email_verified"].(string)
	if ok {
		return emailVerified, nil
	}

	email, ok := (*claim)["email"].(string)
	if ok {
		return email, nil
	}

	return "", errNoEmailFieldsFound
}

const reissueClientSecretDuration = 24 * time.Hour

func (p *appleOAuthProvider) getClientSecret() (string, error) {
	newIssueAt := time.Now()

	if p.issueCache.wasIssuedAtLeastOnce && newIssueAt.Sub(p.issueCache.issuedAt) <= reissueClientSecretDuration {
		return p.issueCache.clientSecret, nil
	}

	clientSecret, err := apple.GenerateClientSecret(p.privateKey, p.teamID, p.clientID, p.keyID)
	if err != nil {
		return "", fmt.Errorf("get bearer token: %w", err)
	}

	p.issueCache = issueCache{
		clientSecret:         clientSecret,
		wasIssuedAtLeastOnce: true,
		issuedAt:             newIssueAt,
	}

	return clientSecret, nil
}
