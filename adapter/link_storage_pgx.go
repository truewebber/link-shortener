package adapter

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	pgxpkg "github.com/truewebber/gopkg/pgx"

	"github.com/truewebber/link-shortener/domain/link"
)

type linkStoragePGX struct {
	pool *pgxpool.Pool
}

func NewLinkStoragePgx(pool *pgxpool.Pool) link.Storage {
	return &linkStoragePGX{
		pool: pool,
	}
}

const (
	//nolint:dupword // false positive, query is correct
	insertLinkRow = `INSERT INTO public.urls 
    (user_id, redirect_url, expires_type, expires_at, created_at, updated_at, deleted)
VALUES ($1, $2, $3, $4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, FALSE)
ON CONFLICT (user_id, md5(redirect_url)) WHERE deleted = false
                                         DO NOTHING
                                         RETURNING id;`

	selectLinkRow = `SELECT id FROM public.urls 
                  WHERE user_id = $1 AND md5(redirect_url) = md5($2) AND deleted = false;`
)

func (s *linkStoragePGX) Create(ctx context.Context, l *link.Link) error {
	txOpts := &pgx.TxOptions{
		IsoLevel: pgx.Serializable,
	}

	doErr := pgxpkg.DoAtomicWithOptions(ctx, s.pool, txOpts, func(doCtx context.Context, tx pgx.Tx) error {
		expiresType, castErr := s.expiresTypeToPGX(l.ExpiresType)
		if castErr != nil {
			return fmt.Errorf("expires type to pgx: %w", castErr)
		}

		err := tx.QueryRow(doCtx, insertLinkRow, l.UserID, l.RedirectURL, expiresType, l.ExpiresAt).
			Scan(&l.ID)
		if err == nil {
			return nil
		}

		if !errors.Is(err, pgx.ErrNoRows) {
			return fmt.Errorf("insert link row: %w", err)
		}

		err = tx.QueryRow(doCtx, selectLinkRow, l.UserID, l.RedirectURL).Scan(&l.ID)
		if err != nil {
			return fmt.Errorf("select existing link row: %w", err)
		}

		return nil
	})
	if doErr != nil {
		return fmt.Errorf("create link on tx: %w", doErr)
	}

	return nil
}

const selectLinkByID = `SELECT id, user_id, redirect_url, expires_type, expires_at, created_at, updated_at
FROM public.urls
WHERE id = $1 AND NOT deleted AND (expires_type=='never' OR expires_at > CURRENT_TIMESTAMP);`

func (s *linkStoragePGX) ByID(ctx context.Context, id uint64) (*link.Link, error) {
	var (
		l           link.Link
		expiresType string
	)

	err := s.pool.QueryRow(ctx, selectLinkByID, id).Scan(
		&l.ID,
		&l.UserID,
		&l.RedirectURL,
		&expiresType,
		&l.ExpiresAt,
		&l.CreatedAt,
		&l.UpdatedAt,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, link.ErrNotFound
	}

	if err != nil {
		return nil, fmt.Errorf("failed to get link: %w", err)
	}

	l.ExpiresType, err = s.expiresTypeFromPGX(expiresType)
	if err != nil {
		return nil, fmt.Errorf("expires type from pgx: %w", err)
	}

	return &l, nil
}

const (
	selectLinksByUserID = `SELECT id, user_id, redirect_url, expires_type, expires_at, created_at, updated_at
FROM urls
WHERE user_id = $1 AND NOT deleted
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;`

	selectCountLinksByUserID = `SELECT count(*) FROM urls
                WHERE user_id = $1 AND NOT deleted AND expires_at > CURRENT_TIMESTAMP;`
)

func (s *linkStoragePGX) ByUserID(ctx context.Context, userID uint64, limit, offset uint32) (link.List, error) {
	list := link.List{}

	doErr := pgxpkg.DoAtomic(ctx, s.pool, func(doCtx context.Context, tx pgx.Tx) error {
		rows, err := tx.Query(doCtx, selectLinksByUserID, userID, limit, offset)
		if err != nil {
			return fmt.Errorf("select links by user id: %w", err)
		}

		defer rows.Close()

		for rows.Next() {
			var (
				l           link.Link
				expiresType string
			)

			scanErr := rows.Scan(
				&l.ID,
				&l.UserID,
				&l.RedirectURL,
				&expiresType,
				&l.ExpiresAt,
				&l.CreatedAt,
				&l.UpdatedAt,
			)
			if scanErr != nil {
				return fmt.Errorf("failed to scan link: %w", scanErr)
			}

			var castErr error

			l.ExpiresType, castErr = s.expiresTypeFromPGX(expiresType)
			if castErr != nil {
				return fmt.Errorf("expires type from pgx: %w", castErr)
			}

			list.Links = append(list.Links, l)
		}

		if rowsErr := rows.Err(); rowsErr != nil {
			return fmt.Errorf("rows: %w", rowsErr)
		}

		if err := tx.QueryRow(doCtx, selectCountLinksByUserID, userID).Scan(&list.Count); err != nil {
			return fmt.Errorf("select count links by user id: %w", err)
		}

		return nil
	})
	if doErr != nil {
		return link.List{}, fmt.Errorf("select links by user id on tx: %w", doErr)
	}

	return list, nil
}

const updateLink = "UPDATE urls SET expires_type = $1, expires_at = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3;"

func (s *linkStoragePGX) Update(ctx context.Context, l *link.Link) error {
	expiresType, err := s.expiresTypeToPGX(l.ExpiresType)
	if err != nil {
		return fmt.Errorf("expires type to pgx: %w", err)
	}

	if _, err := s.pool.Exec(ctx, updateLink, expiresType, l.ExpiresAt, l.ID); err != nil {
		return fmt.Errorf("update link: %w", err)
	}

	return nil
}

const updateLinkSetDeleted = `UPDATE urls SET deleted = true, updated_at = CURRENT_TIMESTAMP
            WHERE id = $1 AND NOT deleted;`

func (s *linkStoragePGX) Delete(ctx context.Context, id uint64) error {
	if _, err := s.pool.Exec(ctx, updateLinkSetDeleted, id); err != nil {
		return fmt.Errorf("set link deleted by id: %w", err)
	}

	return nil
}

const setDeletedExpiredURLs = `UPDATE urls SET deleted = true, updated_at = CURRENT_TIMESTAMP
		WHERE NOT deleted AND expires_at IS NOT NULL AND expires_at <= CURRENT_TIMESTAMP;`

func (s *linkStoragePGX) DeleteAllExpired(ctx context.Context) error {
	if _, err := s.pool.Exec(ctx, setDeletedExpiredURLs); err != nil {
		return fmt.Errorf("set expired links deleted: %w", err)
	}

	return nil
}

const (
	expiresType3Months  = "3months"
	expiresType6Months  = "6months"
	expiresType12Months = "12months"
	expiresTypeNever    = "never"
)

var errUnknownExpiresType = errors.New("unknown expires type")

func (s *linkStoragePGX) expiresTypeToPGX(expiresType link.ExpiresType) (string, error) {
	switch expiresType {
	case link.ExpiresType3Months:
		return expiresType3Months, nil
	case link.ExpiresType6Months:
		return expiresType6Months, nil
	case link.ExpiresType12Months:
		return expiresType12Months, nil
	case link.ExpiresTypeNever:
		return expiresTypeNever, nil
	}

	return "", errUnknownExpiresType
}

func (s *linkStoragePGX) expiresTypeFromPGX(expiresType string) (link.ExpiresType, error) {
	switch expiresType {
	case expiresType3Months:
		return link.ExpiresType3Months, nil
	case expiresType6Months:
		return link.ExpiresType6Months, nil
	case expiresType12Months:
		return link.ExpiresType12Months, nil
	case expiresTypeNever:
		return link.ExpiresTypeNever, nil
	}

	return 0, errUnknownExpiresType
}
