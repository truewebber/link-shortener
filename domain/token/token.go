package token

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"time"
)

type Token struct {
	ExpiresAt time.Time
	CreatedAt time.Time
	UpdatedAt time.Time
	Value     string
	UserID    int64
}

const tokenBytesLen = 32

func NewToken(userID int64, duration time.Duration) (*Token, error) {
	tokenBytes := make([]byte, tokenBytesLen)
	if _, err := rand.Read(tokenBytes); err != nil {
		return nil, fmt.Errorf("generate random value: %w", err)
	}

	tokenValue := hex.EncodeToString(tokenBytes)
	now := time.Now()

	return &Token{
		UserID:    userID,
		Value:     tokenValue,
		ExpiresAt: now.Add(duration),
		CreatedAt: now,
		UpdatedAt: now,
	}, nil
}

type Storage interface {
	Create(ctx context.Context, token *Token) error
	ByValue(ctx context.Context, value string) (*Token, error)
	Delete(ctx context.Context, value string) error
}
