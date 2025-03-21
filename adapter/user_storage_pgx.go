package adapter

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	userdomain "github.com/truewebber/link-shortener/domain/user"
)

type userStoragePgx struct {
	db *pgxpool.Pool
}

func NewUserStoragePgx(db *pgxpool.Pool) userdomain.Storage {
	return &userStoragePgx{db: db}
}

const insertUserQuery = `
		INSERT INTO users (
			provider_type, provider_user_id, provider_user_email, provider_user_name, 
			provider_avatar_url, created_at, updated_at, deleted
		) VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, false)
		  ON CONFLICT DO NOTHING
		RETURNING id, created_at, updated_at;`

func (s *userStoragePgx) Create(ctx context.Context, user *userdomain.User) error {
	err := s.db.QueryRow(
		ctx,
		insertUserQuery,
		user.Provider,
		user.ProviderID,
		user.Email,
		user.Name,
		user.AvatarURL,
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)

	if errors.Is(err, pgx.ErrNoRows) {
		return userdomain.ErrAlreadyExists
	}

	if err != nil {
		return fmt.Errorf("insert user: %w", err)
	}

	return nil
}

const selectUserByIDQuery = `
		SELECT 
			id, provider_type, provider_user_id, provider_user_email, 
			provider_user_name, provider_avatar_url, created_at, updated_at
		FROM users
		WHERE id = $1 AND NOT deleted;`

func (s *userStoragePgx) ByID(ctx context.Context, id uint64) (*userdomain.User, error) {
	u := &userdomain.User{}

	err := s.db.QueryRow(ctx, selectUserByIDQuery, id).Scan(
		&u.ID,
		&u.Provider,
		&u.ProviderID,
		&u.Email,
		&u.Name,
		&u.AvatarURL,
		&u.CreatedAt,
		&u.UpdatedAt,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, userdomain.ErrUserNotFound
	}

	if err != nil {
		return nil, fmt.Errorf("select user by id: %w", err)
	}

	return u, nil
}

const selectUserByProviderQuery = `
		SELECT 
			id, provider_type, provider_user_id, provider_user_email, 
			provider_user_name, provider_avatar_url, created_at, updated_at
		FROM users
		WHERE provider_type = $1 AND provider_user_id = $2 AND NOT deleted;`

func (s *userStoragePgx) ByProviderID(
	ctx context.Context, provider userdomain.Provider, providerID string,
) (*userdomain.User, error) {
	u := &userdomain.User{}

	err := s.db.QueryRow(ctx, selectUserByProviderQuery, provider, providerID).Scan(
		&u.ID,
		&u.Provider,
		&u.ProviderID,
		&u.Email,
		&u.Name,
		&u.AvatarURL,
		&u.CreatedAt,
		&u.UpdatedAt,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, userdomain.ErrUserNotFound
	}

	if err != nil {
		return nil, fmt.Errorf("select user by provider: %w", err)
	}

	return u, nil
}

const updateUserInfoByID = `
		UPDATE users
		SET 
			provider_user_email = $1,
			provider_user_name = $2,
			provider_avatar_url = $3,
			updated_at = $4
		WHERE id = $5 AND NOT deleted;`

func (s *userStoragePgx) Update(ctx context.Context, user *userdomain.User) error {
	updatedAt := time.Now()

	if _, err := s.db.Exec(
		ctx,
		updateUserInfoByID,
		user.Email,
		user.Name,
		user.AvatarURL,
		updatedAt,
		user.ID,
	); err != nil {
		return fmt.Errorf("update user: %w", err)
	}

	user.UpdatedAt = updatedAt

	return nil
}

const setUserDeletedByID = `
		UPDATE users
		SET deleted = true, updated_at = CURRENT_TIMESTAMP 
		WHERE id = $2;`

func (s *userStoragePgx) Delete(ctx context.Context, id uint64) error {
	if _, err := s.db.Exec(ctx, setUserDeletedByID, id); err != nil {
		return fmt.Errorf("delete user: %w", err)
	}

	return nil
}
