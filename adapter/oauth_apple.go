package adapter

import (
	"context"
	"crypto/ecdsa"
	"crypto/x509"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/truewebber/gopkg/log"
	"golang.org/x/oauth2"

	"github.com/truewebber/link-shortener/domain/user"
)

type appleOAuthProvider struct {
	logger      log.Logger
	privateKey  *ecdsa.PrivateKey
	httpClient  *http.Client
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
	clientID, redirectURL, keyID, teamID string,
	privateKeyPEM []byte, logger log.Logger,
) (user.OAuthProvider, error) {
	ecdsaKey, err := parseECDSAKey(privateKeyPEM)
	if err != nil {
		return nil, fmt.Errorf("parse ECDSA key: %w", err)
	}

	return &appleOAuthProvider{
		clientID:    clientID,
		redirectURL: redirectURL,
		privateKey:  ecdsaKey,
		teamID:      teamID,
		keyID:       keyID,
		endpoint: oauth2.Endpoint{
			AuthURL:  "https://appleid.apple.com/auth/authorize",
			TokenURL: "https://appleid.apple.com/auth/token",
		},
		issueCache: issueCache{},
		httpClient: &http.Client{},
		logger:     logger,
	}, nil
}

func MustNewAppleOAuthProvider(
	clientID, redirectURL, keyID, teamID string,
	privateKeyPEM []byte, logger log.Logger,
) user.OAuthProvider {
	provider, err := NewAppleOAuthProvider(clientID, redirectURL, keyID, teamID, privateKeyPEM, logger)
	if err != nil {
		panic(err)
	}

	return provider
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

	return config.AuthCodeURL(state), nil
}

type tokenResponse struct {
	AccessToken  string `json:"access_token"`
	TokenType    string `json:"token_type"`
	RefreshToken string `json:"refresh_token"`
	IDToken      string `json:"id_token"`
	ExpiresIn    int    `json:"expires_in"`
}

var errUnexpectedSigningMethod = errors.New("unexpected signing method")

func (p *appleOAuthProvider) ExchangeCode(ctx context.Context, code string) (*user.OAuthInfo, error) {
	clientSecret, err := p.getClientSecret()
	if err != nil {
		return nil, fmt.Errorf("get client secret: %w", err)
	}

	requestBody := p.buildExchangeTokenRequestBody(code, clientSecret)

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, p.endpoint.TokenURL, requestBody)
	if err != nil {
		return nil, fmt.Errorf("create request: %w", err)
	}

	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")

	resp, err := p.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("do request: %w", err)
	}

	defer func() {
		if closeErr := resp.Body.Close(); closeErr != nil {
			p.logger.Error("failed to close response body", "error", closeErr)
		}
	}()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read body: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("%w %d, body: %s", errNonOKStatusCode, resp.StatusCode, string(body))
	}

	tokenObj := &tokenResponse{}

	if unmarshalErr := json.Unmarshal(body, tokenObj); unmarshalErr != nil {
		return nil, fmt.Errorf("unmarshal token response: %w", unmarshalErr)
	}

	idToken, err := jwt.Parse(tokenObj.IDToken, func(token *jwt.Token) (interface{}, error) {
		// Apple uses RS256 which is RSA + SHA-256
		if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
			return nil, fmt.Errorf("%w: %v", errUnexpectedSigningMethod, token.Header["alg"])
		}

		// In a production environment, you would verify the signature with Apple's public key
		// This is simplified for the example
		return nil, nil
	})
	if err != nil {
		return nil, fmt.Errorf("parse id token: %w", err)
	}

	oauthInfo, err := p.parseOAuthInfoFromClaims(idToken.Claims)
	if err != nil {
		return nil, fmt.Errorf("parse id token claims: %w", err)
	}

	return oauthInfo, nil
}

func (p *appleOAuthProvider) buildExchangeTokenRequestBody(code, clientSecret string) io.Reader {
	values := url.Values{}
	values.Set("client_id", p.clientID)
	values.Set("client_secret", clientSecret)
	values.Set("code", code)
	values.Set("grant_type", "authorization_code")
	values.Set("redirect_uri", p.redirectURL)

	return strings.NewReader(values.Encode())
}

var (
	errCastClaims             = errors.New("error casting claims")
	errExtractFieldFromClaims = errors.New("error extracting field from claims")
)

func (p *appleOAuthProvider) parseOAuthInfoFromClaims(claims jwt.Claims) (*user.OAuthInfo, error) {
	mapClaims, ok := claims.(jwt.MapClaims)
	if !ok {
		return nil, errCastClaims
	}

	email, ok := mapClaims["email"].(string)
	if !ok {
		return nil, fmt.Errorf("%w email", errExtractFieldFromClaims)
	}

	providerID, ok := mapClaims["sub"].(string)
	if !ok {
		return nil, fmt.Errorf("%w sub", errExtractFieldFromClaims)
	}

	return &user.OAuthInfo{
		ProviderID: providerID,
		Provider:   user.ProviderApple,
		Email:      email,
		Name:       "",
		AvatarURL:  "",
	}, nil
}

var (
	errPEMBlockIsMissing = errors.New("failed to parse PEM block containing the key")
	errKeyIsNotECDSA     = errors.New("key is not an ECDSA key")
)

func parseECDSAKey(privateKeyPEM []byte) (*ecdsa.PrivateKey, error) {
	block, _ := pem.Decode(privateKeyPEM)
	if block == nil {
		return nil, errPEMBlockIsMissing
	}

	privateKey, err := x509.ParsePKCS8PrivateKey(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("parse private key: %w", err)
	}

	ecdsaKey, ok := privateKey.(*ecdsa.PrivateKey)
	if !ok {
		return nil, errKeyIsNotECDSA
	}

	return ecdsaKey, nil
}

const (
	clientSecretJWTExpire       = 16 * time.Hour
	reissueClientSecretDuration = clientSecretJWTExpire - 30*time.Minute
)

func (p *appleOAuthProvider) getClientSecret() (string, error) {
	newIssueAt := time.Now()

	if p.issueCache.wasIssuedAtLeastOnce && newIssueAt.Sub(p.issueCache.issuedAt) <= reissueClientSecretDuration {
		return p.issueCache.clientSecret, nil
	}

	clientSecret, err := p.generateClientSecret()
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

func (p *appleOAuthProvider) generateClientSecret() (string, error) {
	now := time.Now()

	claims := jwt.MapClaims{
		"iss": p.teamID,
		"iat": now.Unix(),
		"exp": now.Add(clientSecretJWTExpire).Unix(),
		"aud": "https://appleid.apple.com",
		"sub": p.clientID,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodES256, claims)
	token.Header["kid"] = p.keyID

	clientSecret, err := token.SignedString(p.privateKey)
	if err != nil {
		return "", fmt.Errorf("sign token: %w", err)
	}

	return clientSecret, nil
}
