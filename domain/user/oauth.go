package user

import "context"

type OAuthInfo struct {
	ProviderID string
	Email      string
	Name       string
	AvatarURL  string
	Provider   Provider
}

type OAuthProvider interface {
	GetAuthURL(state string) (string, error)
	ExchangeCode(ctx context.Context, code string) (*OAuthInfo, error)
}
