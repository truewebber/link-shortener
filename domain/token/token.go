package token

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"errors"
	"time"
)

type Token struct {
	AccessTokenExpiresAt  time.Time
	RefreshTokenExpiresAt time.Time
	CreatedAt             time.Time
	UpdatedAt             time.Time
	AccessToken           string
	RefreshToken          string
	ID                    uint64
	UserID                uint64
}

func (t *Token) CanBeAuthorized() bool {
	return time.Now().Before(t.AccessTokenExpiresAt)
}

func (t *Token) CanBeRefreshed() bool {
	return time.Now().Before(t.RefreshTokenExpiresAt)
}

func GenerateNewToken(userID uint64, accessTokenDuration, refreshTokenDuration time.Duration) (*Token, error) {
	accessToken := generateTokenString()
	refreshToken := generateTokenString()

	now := time.Now()

	return &Token{
		UserID:                userID,
		AccessToken:           accessToken,
		RefreshToken:          refreshToken,
		AccessTokenExpiresAt:  now.Add(accessTokenDuration),
		RefreshTokenExpiresAt: now.Add(refreshTokenDuration),
	}, nil
}

const tokenBytesLen = 50

func generateTokenString() string {
	tokenBytes := make([]byte, tokenBytesLen)

	rand.Read(tokenBytes)

	return base64.URLEncoding.EncodeToString(tokenBytes)
}

var (
	ErrTokenNotFound = errors.New("token not found")
	ErrTokenExpired  = errors.New("token expired")
	ErrInvalidToken  = errors.New("invalid token")
)

type Storage interface {
	Create(ctx context.Context, token *Token) error
	ByAccessToken(ctx context.Context, value string) (*Token, error)
	ByRefreshToken(ctx context.Context, value string) (*Token, error)
	DeleteByID(ctx context.Context, id uint64) error
	DeleteByUserID(ctx context.Context, userID uint64) error
}
