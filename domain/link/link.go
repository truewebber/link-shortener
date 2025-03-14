package link

import (
	"context"
	"errors"
	"fmt"
	"time"
)

type Link struct {
	CreatedAt   time.Time
	UpdatedAt   time.Time
	ExpiresAt   *time.Time
	RedirectURL string
	ID          uint64
	UserID      uint64
	ExpiresType ExpiresType
}

type List struct {
	Links []Link
	Count uint32
}

type ExpiresType uint8

const (
	ExpiresType3Months ExpiresType = iota + 1
	ExpiresType6Months
	ExpiresType12Months
	ExpiresTypeNever
)

var ErrNotFound = errors.New("link not found")

type Storage interface {
	ByID(ctx context.Context, id uint64) (*Link, error)
	ByUserID(ctx context.Context, userID uint64, limit, offset uint32) (List, error)
	Create(ctx context.Context, link *Link) error
	Update(ctx context.Context, link *Link) error
	Delete(ctx context.Context, id uint64) error
	DeleteAllExpired(ctx context.Context) error
}

func New(userID uint64, redirectURL string, expiresType ExpiresType) (*Link, error) {
	now := time.Now()

	linkExpiresAt, err := expiresAt(expiresType)
	if err != nil {
		return nil, fmt.Errorf("link expires at: %w", err)
	}

	return &Link{
		ID:          0,
		UserID:      userID,
		RedirectURL: redirectURL,
		ExpiresType: expiresType,
		ExpiresAt:   linkExpiresAt,
		CreatedAt:   now,
		UpdatedAt:   now,
	}, nil
}

const (
	threeMonths  = 3
	sixMonths    = 6
	twelveMonths = 12
)

var errUnknownExpiresType = errors.New("unknown expires type")

func expiresAt(expiresType ExpiresType) (*time.Time, error) {
	at := time.Now()

	switch expiresType {
	case ExpiresType3Months:
		at = at.AddDate(0, threeMonths, 0)
	case ExpiresType6Months:
		at = at.AddDate(0, sixMonths, 0)
	case ExpiresType12Months:
		at = at.AddDate(0, twelveMonths, 0)
	case ExpiresTypeNever:
		//nolint:nilnil // expiresAt is disabled and that's not an error
		return nil, nil
	default:
		return nil, errUnknownExpiresType
	}

	return &at, nil
}
