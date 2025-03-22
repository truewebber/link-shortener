package query

import (
	"context"
	"errors"
	"fmt"

	"github.com/truewebber/link-shortener/app/types"
	userdomain "github.com/truewebber/link-shortener/domain/user"
)

type GetAuthURLHandler struct {
	oauthProviders map[types.Provider]userdomain.OAuthProvider
}

func NewGetAuthURLHandler(oauthProviders map[types.Provider]userdomain.OAuthProvider) *GetAuthURLHandler {
	return &GetAuthURLHandler{
		oauthProviders: oauthProviders,
	}
}

type AuthURLResponse struct {
	URL string
}

func (h *GetAuthURLHandler) Handle(
	_ context.Context, provider types.Provider, state string,
) (AuthURLResponse, error) {
	oauthProvider, err := h.getOAuthProvider(provider)
	if err != nil {
		return AuthURLResponse{}, fmt.Errorf("get OAuth provider: %w", err)
	}

	url, err := oauthProvider.GetAuthURL(state)
	if err != nil {
		return AuthURLResponse{}, fmt.Errorf("get auth URL from oauthProvider: %w", err)
	}

	return AuthURLResponse{
		URL: url,
	}, nil
}

var errUnknownProvider = errors.New("unknown provider")

func (h *GetAuthURLHandler) getOAuthProvider(provider types.Provider) (userdomain.OAuthProvider, error) {
	oauthProvider, ok := h.oauthProviders[provider]
	if !ok {
		return nil, errUnknownProvider
	}

	return oauthProvider, nil
}
