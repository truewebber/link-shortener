package types

import (
	"time"

	tokendomain "github.com/truewebber/link-shortener/domain/token"
)

type Token struct {
	AccessTokenExpiresAt  time.Time
	RefreshTokenExpiresAt time.Time
	AccessToken           string
	RefreshToken          string
	ID                    uint64
	UserID                uint64
}

func BuildTokenFromDomain(token *tokendomain.Token) *Token {
	return &Token{
		AccessTokenExpiresAt:  token.AccessTokenExpiresAt,
		RefreshTokenExpiresAt: token.RefreshTokenExpiresAt,
		AccessToken:           token.AccessToken,
		RefreshToken:          token.RefreshToken,
		ID:                    token.ID,
		UserID:                token.UserID,
	}
}
