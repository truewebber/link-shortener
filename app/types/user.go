package types

import (
	"fmt"
	userdomain "github.com/truewebber/link-shortener/domain/user"
)

type User struct {
	Name       string
	Email      string
	ProviderID string
	AvatarURL  string
	ID         uint64
	Provider   Provider
}

func BuildUserFromDomain(user *userdomain.User) (*User, error) {
	provider, err := BuildProviderFromDomain(user.Provider)
	if err != nil {
		return nil, fmt.Errorf("build user provider: %w", err)
	}

	return &User{
		Name:       user.Name,
		Email:      user.Email,
		ID:         user.ID,
		Provider:   provider,
		ProviderID: user.ProviderID,
		AvatarURL:  user.AvatarURL,
	}, nil
}

func BuildUserToDomain(user *User) (*userdomain.User, error) {
	provider, err := BuildProviderToDomain(user.Provider)
	if err != nil {
		return nil, fmt.Errorf("build user provider: %w", err)
	}

	return &userdomain.User{
		Name:       user.Name,
		Email:      user.Email,
		ID:         user.ID,
		Provider:   provider,
		ProviderID: user.ProviderID,
		AvatarURL:  user.AvatarURL,
	}, nil
}

func AnonymousUser() *User {
	return &User{
		ID:         1,
		Name:       "Anonymous",
		Email:      "anonymous@example.com",
		Provider:   ProviderAnonymous,
		ProviderID: "anonymous_provider_id",
	}
}
