package query

import (
	"context"
	"errors"
	"fmt"

	apperrors "github.com/truewebber/link-shortener/app/errors"
	"github.com/truewebber/link-shortener/app/types"
	tokendomain "github.com/truewebber/link-shortener/domain/token"
	userdomain "github.com/truewebber/link-shortener/domain/user"
)

type AuthUserHandler struct {
	userStorage  userdomain.Storage
	tokenStorage tokendomain.Storage
}

func NewAuthUserHandler(
	userStorage userdomain.Storage,
	tokenStorage tokendomain.Storage,
) *AuthUserHandler {
	return &AuthUserHandler{
		userStorage:  userStorage,
		tokenStorage: tokenStorage,
	}
}

func (h *AuthUserHandler) Handle(ctx context.Context, accessToken string) (*types.User, error) {
	token, err := h.tokenStorage.ByAccessToken(ctx, accessToken)
	if errors.Is(err, tokendomain.ErrTokenNotFound) {
		return nil, apperrors.ErrInvalidCredentials
	}

	if err != nil {
		return nil, fmt.Errorf("find token: %w", err)
	}

	if !token.CanBeAuthorized() {
		return nil, apperrors.ErrTokenExpired
	}

	user, err := h.userStorage.ByID(ctx, token.UserID)
	if errors.Is(err, userdomain.ErrUserNotFound) {
		return nil, apperrors.ErrUserNotFound
	}

	if err != nil {
		return nil, fmt.Errorf("find user: %w", err)
	}

	builtUser, err := types.BuildUserFromDomain(user)
	if err != nil {
		return nil, fmt.Errorf("build user from domain: %w", err)
	}

	return builtUser, nil
}
