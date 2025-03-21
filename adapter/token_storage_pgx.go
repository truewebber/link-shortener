package adapter

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	tokendomain "github.com/truewebber/link-shortener/domain/token"
)

type tokenStoragePgx struct {
	db *pgxpool.Pool
}

func NewTokenStoragePgx(db *pgxpool.Pool) tokendomain.Storage {
	return &tokenStoragePgx{db: db}
}

//nolint:dupword // CURRENT_TIMESTAMP used twice for two different fields.
const insertTokenQuery = `
			INSERT INTO tokens (
				user_id, access_token, refresh_token, 
				access_token_expires_at, refresh_token_expires_at, 
				created_at, updated_at, deleted
			) VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, false)
			RETURNING id, created_at, updated_at;`

func (s *tokenStoragePgx) Create(ctx context.Context, token *tokendomain.Token) error {
	if err := s.db.QueryRow(
		ctx,
		insertTokenQuery,
		token.UserID,
		token.AccessToken,
		token.RefreshToken,
		token.AccessTokenExpiresAt,
		token.RefreshTokenExpiresAt,
	).Scan(&token.ID, &token.CreatedAt, &token.UpdatedAt); err != nil {
		return fmt.Errorf("insert token: %w", err)
	}

	return nil
}

//nolint:gosec // false positive
const selectTokenByAccessTokenQuery = `
		SELECT 
			id, user_id, access_token, refresh_token, access_token_expires_at,
			refresh_token_expires_at, created_at, updated_at
		FROM tokens
		WHERE access_token = $1 AND NOT deleted;`

func (s *tokenStoragePgx) ByAccessToken(ctx context.Context, accessToken string) (*tokendomain.Token, error) {
	t, err := s.selectToken(ctx, selectTokenByAccessTokenQuery, accessToken)
	if err != nil {
		return nil, fmt.Errorf("select token by accessToken: %w", err)
	}

	return t, nil
}

//nolint:gosec // false positive
const selectTokenByRefreshTokenQuery = `
		SELECT 
			id, user_id, access_token, refresh_token, access_token_expires_at,
			refresh_token_expires_at, created_at, updated_at
		FROM tokens
		WHERE refresh_token = $1 AND NOT deleted;`

func (s *tokenStoragePgx) ByRefreshToken(ctx context.Context, refreshToken string) (*tokendomain.Token, error) {
	t, err := s.selectToken(ctx, selectTokenByRefreshTokenQuery, refreshToken)
	if err != nil {
		return nil, fmt.Errorf("select token by refreshToken: %w", err)
	}

	return t, nil
}

func (s *tokenStoragePgx) selectToken(
	ctx context.Context, sql string, tokenValue string,
) (*tokendomain.Token, error) {
	t := &tokendomain.Token{}

	err := s.db.QueryRow(ctx, sql, tokenValue).Scan(
		&t.ID,
		&t.UserID,
		&t.AccessToken,
		&t.RefreshToken,
		&t.AccessTokenExpiresAt,
		&t.RefreshTokenExpiresAt,
		&t.CreatedAt,
		&t.UpdatedAt,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, tokendomain.ErrTokenNotFound
	}

	if err != nil {
		return nil, fmt.Errorf("select token: %w", err)
	}

	return t, nil
}

//nolint:gosec // false positive
const setTokenDeletedByID = "UPDATE tokens SET deleted = true WHERE id = $1;"

func (s *tokenStoragePgx) DeleteByID(ctx context.Context, id uint64) error {
	if _, err := s.db.Exec(ctx, setTokenDeletedByID, id); err != nil {
		return fmt.Errorf("exec update set token deleted by id: %w", err)
	}

	return nil
}

//nolint:gosec // false positive
const setTokenDeletedByUserID = "UPDATE tokens SET deleted = true WHERE user_id = $1"

func (s *tokenStoragePgx) DeleteByUserID(ctx context.Context, userID uint64) error {
	if _, err := s.db.Exec(ctx, setTokenDeletedByUserID, userID); err != nil {
		return fmt.Errorf("exec update set token deleted by user id: %w", err)
	}

	return nil
}
