package command

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/truewebber/gopkg/log"

	"github.com/truewebber/link-shortener/app/types"
	tokendomain "github.com/truewebber/link-shortener/domain/token"
	userdomain "github.com/truewebber/link-shortener/domain/user"
)

type FinishOAuthHandler struct {
	userStorage    userdomain.Storage
	tokenStorage   tokendomain.Storage
	oauthProviders map[types.Provider]userdomain.OAuthProvider
	logger         log.Logger
}

func NewFinishOAuthHandler(
	userStorage userdomain.Storage,
	tokenStorage tokendomain.Storage,
	oauthProviders map[types.Provider]userdomain.OAuthProvider,
	logger log.Logger,
) *FinishOAuthHandler {
	return &FinishOAuthHandler{
		userStorage:    userStorage,
		tokenStorage:   tokenStorage,
		oauthProviders: oauthProviders,
		logger:         logger,
	}
}

type FinishOAuthParams struct {
	Code         string
	ErrorMessage string
	UserData     []byte
	Provider     types.Provider
}

const (
	AccessTokenDuration  = 1 * time.Hour
	RefreshTokenDuration = 30 * 24 * time.Hour
)

func (h *FinishOAuthHandler) Handle(ctx context.Context, params FinishOAuthParams) (*types.Auth, error) {
	oauthProvider, err := h.getOAuthProvider(params.Provider)
	if err != nil {
		return nil, fmt.Errorf("get oauth provider: %w", err)
	}

	oauthInfo, err := oauthProvider.ExchangeCode(ctx, params.Code)
	if err != nil {
		return nil, fmt.Errorf("exchange code: %w", err)
	}

	h.mixInName(oauthInfo, params.UserData)

	provider, err := types.BuildProviderToDomain(params.Provider)
	if err != nil {
		return nil, fmt.Errorf("build provider domain: %w", err)
	}

	user, err := h.upsertUser(
		ctx, provider, oauthInfo.ProviderID, oauthInfo.Email, oauthInfo.Name, oauthInfo.AvatarURL,
	)
	if err != nil {
		return nil, fmt.Errorf("upsert user: %w", err)
	}

	token, err := h.generateAndSaveNewToken(ctx, user)
	if err != nil {
		return nil, fmt.Errorf("generate and save new token: %w", err)
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

type appleUserData struct {
	Name struct {
		FirstName string `json:"firstName"`
		LastName  string `json:"lastName"`
	} `json:"name"`
}

func (h *FinishOAuthHandler) mixInName(oauthInfo *userdomain.OAuthInfo, userData []byte) {
	if oauthInfo.Name != "" {
		return
	}

	appleName := h.getNameFromAppleUserData(userData)
	if appleName == "" {
		return
	}

	oauthInfo.Name = appleName
}

func (h *FinishOAuthHandler) getNameFromAppleUserData(userData []byte) string {
	if len(userData) == 0 {
		return ""
	}

	userDataObj := &appleUserData{}

	if err := json.Unmarshal(userData, userDataObj); err != nil {
		h.logger.Error("unknown user data schema", "user_data", string(userData), "error", err)

		return ""
	}

	return userDataObj.Name.FirstName + " " + userDataObj.Name.LastName
}

var errUnknownProvider = errors.New("unknown provider")

func (h *FinishOAuthHandler) getOAuthProvider(provider types.Provider) (userdomain.OAuthProvider, error) {
	oauthProvider, ok := h.oauthProviders[provider]
	if !ok {
		return nil, errUnknownProvider
	}

	return oauthProvider, nil
}

func (h *FinishOAuthHandler) generateAndSaveNewToken(
	ctx context.Context, user *userdomain.User,
) (*tokendomain.Token, error) {
	token, err := tokendomain.GenerateNewToken(user.ID, AccessTokenDuration, RefreshTokenDuration)
	if err != nil {
		return nil, fmt.Errorf("generate token pair: %w", err)
	}

	if createErr := h.tokenStorage.Create(ctx, token); createErr != nil {
		return nil, fmt.Errorf("create token: %w", createErr)
	}

	return token, nil
}

func (h *FinishOAuthHandler) upsertUser(
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
