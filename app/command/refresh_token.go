package command

import (
	"context"
	"errors"
	"fmt"

	apperrors "github.com/truewebber/link-shortener/app/errors"
	"github.com/truewebber/link-shortener/app/types"
	tokendomain "github.com/truewebber/link-shortener/domain/token"
	userdomain "github.com/truewebber/link-shortener/domain/user"
)

type RefreshTokenHandler struct {
	userStorage  userdomain.Storage
	tokenStorage tokendomain.Storage
}

func NewRefreshTokenHandler(
	userStorage userdomain.Storage,
	tokenStorage tokendomain.Storage,
) *RefreshTokenHandler {
	return &RefreshTokenHandler{
		userStorage:  userStorage,
		tokenStorage: tokenStorage,
	}
}

func (h *RefreshTokenHandler) Handle(ctx context.Context, refreshTokenString string) (*types.Auth, error) {
	token, err := h.tokenStorage.ByRefreshToken(ctx, refreshTokenString)
	if errors.Is(err, tokendomain.ErrTokenNotFound) {
		return nil, apperrors.ErrInvalidCredentials
	}

	if err != nil {
		return nil, fmt.Errorf("find refresh token: %w", err)
	}

	if !token.CanBeRefreshed() {
		return nil, apperrors.ErrTokenExpired
	}

	user, err := h.userStorage.ByID(ctx, token.UserID)
	if errors.Is(err, userdomain.ErrUserNotFound) {
		return nil, apperrors.ErrUserNotFound
	}

	if err != nil {
		return nil, fmt.Errorf("find user: %w", err)
	}

	newToken, err := tokendomain.GenerateNewToken(user.ID, AccessTokenDuration, RefreshTokenDuration)
	if err != nil {
		return nil, fmt.Errorf("generate new token: %w", err)
	}

	if createErr := h.tokenStorage.Create(ctx, newToken); createErr != nil {
		return nil, fmt.Errorf("create token: %w", createErr)
	}

	if deleteErr := h.tokenStorage.DeleteByID(ctx, token.ID); deleteErr != nil {
		return nil, fmt.Errorf("delete token: %w", deleteErr)
	}

	builtUser, err := types.BuildUserFromDomain(user)
	if err != nil {
		return nil, fmt.Errorf("build user from domain: %w", err)
	}

	return &types.Auth{
		Token: types.BuildTokenFromDomain(newToken),
		User:  builtUser,
	}, nil
}
