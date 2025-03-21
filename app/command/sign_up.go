package command

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/truewebber/link-shortener/app/types"
	tokendomain "github.com/truewebber/link-shortener/domain/token"
	userdomain "github.com/truewebber/link-shortener/domain/user"
)

type SignUpHandler struct {
	userStorage  userdomain.Storage
	tokenStorage tokendomain.Storage
}

func NewSignUpHandler(
	userStorage userdomain.Storage,
	tokenStorage tokendomain.Storage,
) *SignUpHandler {
	return &SignUpHandler{
		userStorage:  userStorage,
		tokenStorage: tokenStorage,
	}
}

type SignUpParams struct {
	ProviderID string
	Email      string
	Name       string
	AvatarURL  string
	Provider   types.Provider
}

const (
	AccessTokenDuration  = 1 * time.Hour
	RefreshTokenDuration = 30 * 24 * time.Hour
)

// Handle TODO: check if real callback or what ever.
func (h *SignUpHandler) Handle(ctx context.Context, params SignUpParams) (*types.Auth, error) {
	provider, err := types.BuildProviderToDomain(params.Provider)
	if err != nil {
		return nil, fmt.Errorf("build provider domain: %w", err)
	}

	user, err := h.upsertUser(
		ctx, provider, params.ProviderID, params.Email, params.Name, params.AvatarURL,
	)
	if err != nil {
		return nil, fmt.Errorf("upsert user: %w", err)
	}

	token, err := tokendomain.GenerateNewToken(user.ID, AccessTokenDuration, RefreshTokenDuration)
	if err != nil {
		return nil, fmt.Errorf("generate token pair: %w", err)
	}

	if createErr := h.tokenStorage.Create(ctx, token); createErr != nil {
		return nil, fmt.Errorf("create token: %w", createErr)
	}

	builtUser, err := types.BuildUserFromDomain(user)
	if err != nil {
		return nil, fmt.Errorf("build user: %w", err)
	}

	return &types.Auth{
		AccessToken:  token.AccessToken,
		RefreshToken: token.RefreshToken,
		User:         builtUser,
	}, nil
}

func (h *SignUpHandler) upsertUser(
	ctx context.Context,
	provider userdomain.Provider,
	providerID, email, name, avatarURL string,
) (*userdomain.User, error) {
	existingUser, err := h.userStorage.ByProviderID(ctx, provider, providerID)
	if err != nil && !errors.Is(err, userdomain.ErrUserNotFound) {
		return nil, fmt.Errorf("find userdomain by provider: %w", err)
	}

	userToUpsert := &userdomain.User{
		Provider:   provider,
		ProviderID: providerID,
		Email:      email,
		Name:       name,
		AvatarURL:  avatarURL,
	}

	if errors.Is(err, userdomain.ErrUserNotFound) {
		if err := h.userStorage.Create(ctx, userToUpsert); err != nil {
			return nil, fmt.Errorf("create user: %w", err)
		}

		return userToUpsert, nil
	}

	userToUpsert.ID = existingUser.ID

	updated := false

	if existingUser.Email != email {
		userToUpsert.Email = email
		updated = true
	}

	if existingUser.Name != name {
		userToUpsert.Name = name
		updated = true
	}

	if existingUser.AvatarURL != avatarURL {
		userToUpsert.AvatarURL = avatarURL
		updated = true
	}

	if !updated {
		return existingUser, nil
	}

	if err := h.userStorage.Update(ctx, userToUpsert); err != nil {
		return nil, fmt.Errorf("update user: %w", err)
	}

	return userToUpsert, nil
}
