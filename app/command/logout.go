package command

import (
	"context"
	"errors"
	"fmt"

	apperrors "github.com/truewebber/link-shortener/app/errors"
	tokendomain "github.com/truewebber/link-shortener/domain/token"
	userdomain "github.com/truewebber/link-shortener/domain/user"
)

type LogoutHandler struct {
	userStorage  userdomain.Storage
	tokenStorage tokendomain.Storage
}

func NewLogoutHandler(
	userStorage userdomain.Storage,
	tokenStorage tokendomain.Storage,
) *LogoutHandler {
	return &LogoutHandler{
		userStorage:  userStorage,
		tokenStorage: tokenStorage,
	}
}

func (h *LogoutHandler) Handle(ctx context.Context, accessToken string) error {
	token, err := h.tokenStorage.ByAccessToken(ctx, accessToken)
	if errors.Is(err, tokendomain.ErrTokenNotFound) {
		return apperrors.ErrInvalidCredentials
	}

	if err != nil {
		return fmt.Errorf("find token: %w", err)
	}

	if !token.CanBeAuthorized() {
		return apperrors.ErrTokenExpired
	}

	if err := h.tokenStorage.DeleteByID(ctx, token.ID); err != nil {
		return fmt.Errorf("delete token: %w", err)
	}

	return nil
}
