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

//nolint:dupword // CURRENT_TIMESTAMP used twice for two different fields.
const insertUserQuery = `
		INSERT INTO users (
			provider_type, provider_user_id, provider_user_email, provider_user_name, 
			provider_avatar_url, created_at, updated_at, deleted
		) VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, false)
		  ON CONFLICT DO NOTHING
		RETURNING id, created_at, updated_at;`

func (s *userStoragePgx) Create(ctx context.Context, user *userdomain.User) error {
	providerType, err := s.buildProviderTypePGX(user.Provider)
	if err != nil {
		return fmt.Errorf("build provider type pgx: %w", err)
	}

	queryErr := s.db.QueryRow(
		ctx,
		insertUserQuery,
		providerType,
		user.ProviderID,
		user.Email,
		user.Name,
		user.AvatarURL,
	).Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)

	if errors.Is(queryErr, pgx.ErrNoRows) {
		return userdomain.ErrAlreadyExists
	}

	if queryErr != nil {
		return fmt.Errorf("insert user: %w", queryErr)
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
	user := &userdomain.User{}
	providerType := uint8(0)

	err := s.db.QueryRow(ctx, selectUserByIDQuery, id).Scan(
		&user.ID,
		&providerType,
		&user.ProviderID,
		&user.Email,
		&user.Name,
		&user.AvatarURL,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, userdomain.ErrUserNotFound
	}

	if err != nil {
		return nil, fmt.Errorf("select user by id: %w", err)
	}

	user.Provider, err = s.buildProviderTypeDomain(providerType)
	if err != nil {
		return nil, fmt.Errorf("build provider type domain: %w", err)
	}

	return user, nil
}

const selectUserByProviderQuery = `
		SELECT 
			id, provider_user_email, provider_user_name,
			provider_avatar_url, created_at, updated_at
		FROM users
		WHERE provider_type = $1 AND provider_user_id = $2 AND NOT deleted;`

func (s *userStoragePgx) ByProviderID(
	ctx context.Context, provider userdomain.Provider, providerID string,
) (*userdomain.User, error) {
	user := &userdomain.User{}

	providerType, err := s.buildProviderTypePGX(provider)
	if err != nil {
		return nil, fmt.Errorf("build provider type pgx: %w", err)
	}

	queryErr := s.db.QueryRow(ctx, selectUserByProviderQuery, providerType, providerID).Scan(
		&user.ID,
		&user.Email,
		&user.Name,
		&user.AvatarURL,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if errors.Is(queryErr, pgx.ErrNoRows) {
		return nil, userdomain.ErrUserNotFound
	}

	if queryErr != nil {
		return nil, fmt.Errorf("select user by provider: %w", queryErr)
	}

	user.ProviderID = providerID
	user.Provider = provider

	return user, nil
}

const updateUserInfoByID = `
		UPDATE users
		SET 
			provider_user_email = $1,
			provider_user_name = $2,
			provider_avatar_url = $3,
			updated_at = $4
		WHERE id = $5 AND NOT deleted;`

const exactOneRowShouldBeUpdated = 1

var errWrongAmountOfRowsAffected = errors.New("wrong amount of rows affected")

func (s *userStoragePgx) Update(ctx context.Context, user *userdomain.User) error {
	updatedAt := time.Now()

	cmd, err := s.db.Exec(
		ctx,
		updateUserInfoByID,
		user.Email,
		user.Name,
		user.AvatarURL,
		updatedAt,
		user.ID,
	)
	if err != nil {
		return fmt.Errorf("update user: %w", err)
	}

	if rowsAffected := cmd.RowsAffected(); rowsAffected != exactOneRowShouldBeUpdated {
		return fmt.Errorf("%w: %v", errWrongAmountOfRowsAffected, rowsAffected)
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

const (
	providerTypeAnonymous = 1
	providerTypeGoogle    = 2
	providerTypeApple     = 3
	providerTypeGithub    = 4
)

var errUnknownProviderType = errors.New("unknown provider type")

func (s *userStoragePgx) buildProviderTypePGX(provider userdomain.Provider) (uint8, error) {
	switch provider {
	case userdomain.ProviderAnonymous:
		return providerTypeAnonymous, nil
	case userdomain.ProviderGoogle:
		return providerTypeGoogle, nil
	case userdomain.ProviderApple:
		return providerTypeApple, nil
	case userdomain.ProviderGithub:
		return providerTypeGithub, nil
	}

	return 0, errUnknownProviderType
}

func (s *userStoragePgx) buildProviderTypeDomain(provider uint8) (userdomain.Provider, error) {
	switch provider {
	case providerTypeAnonymous:
		return userdomain.ProviderAnonymous, nil
	case providerTypeGoogle:
		return userdomain.ProviderGoogle, nil
	case providerTypeApple:
		return userdomain.ProviderApple, nil
	case providerTypeGithub:
		return userdomain.ProviderGithub, nil
	}

	return 0, errUnknownProviderType
}
