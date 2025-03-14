package user

import (
	"context"
	"time"
)

type User struct {
	CreatedAt time.Time
	UpdatedAt time.Time
	Name      string
	Email     string
	ID        uint64
}

func AnonymousUser() *User {
	now := time.Time{}

	return &User{
		ID:        1,
		Name:      "Anonymous",
		CreatedAt: now,
		UpdatedAt: now,
	}
}

type Storage interface {
	Create(ctx context.Context, user *User) error
	ByID(ctx context.Context, id uint64) (*User, error)
	Delete(ctx context.Context, id uint64) error
}
