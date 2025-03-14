package adapter

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

func NewPgxPool(ctx context.Context, connString string) (*pgxpool.Pool, error) {
	pool, err := pgxpool.New(ctx, connString)
	if err != nil {
		return nil, fmt.Errorf("create connection pool: %w", err)
	}

	if pingErr := pool.Ping(ctx); pingErr != nil {
		return nil, fmt.Errorf("ping database: %w", pingErr)
	}

	return pool, nil
}

func MustNewPgxPool(ctx context.Context, connString string) *pgxpool.Pool {
	pool, err := pgxpool.New(ctx, connString)
	if err != nil {
		panic(err)
	}

	return pool
}
