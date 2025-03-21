package user

import (
	"context"
	"errors"
	"time"
)

type User struct {
	CreatedAt  time.Time
	UpdatedAt  time.Time
	Name       string
	Email      string
	ProviderID string
	AvatarURL  string
	ID         uint64
	Provider   Provider
}

var (
	ErrUserNotFound  = errors.New("user not found")
	ErrAlreadyExists = errors.New("user already exists")
)

type Storage interface {
	Create(ctx context.Context, user *User) error
	ByID(ctx context.Context, id uint64) (*User, error)
	ByProviderID(ctx context.Context, provider Provider, providerID string) (*User, error)
	Delete(ctx context.Context, id uint64) error
	Update(ctx context.Context, user *User) error
}
