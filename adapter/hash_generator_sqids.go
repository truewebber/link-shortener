package adapter

import (
	"errors"
	"fmt"

	"github.com/sqids/sqids-go"

	"github.com/truewebber/link-shortener/domain/hash"
)

type wrapper struct {
	sqids *sqids.Sqids
}

func NewHashGenerator() (hash.Generator, error) {
	const minLength = 6

	s, err := sqids.New(sqids.Options{
		MinLength: minLength,
	})
	if err != nil {
		return nil, fmt.Errorf("new sqids: %w", err)
	}

	return &wrapper{
		sqids: s,
	}, nil
}

func MustNewHashGenerator() hash.Generator {
	generator, err := NewHashGenerator()
	if err != nil {
		panic(err)
	}

	return generator
}

func (g *wrapper) ToHash(id uint64) (string, error) {
	h, err := g.sqids.Encode([]uint64{id})
	if err != nil {
		return "", fmt.Errorf("encode sqids: %w", err)
	}

	return h, nil
}

var errInvalidHash = errors.New("invalid hash")

func (g *wrapper) FromHash(hash string) (uint64, error) {
	ids := g.sqids.Decode(hash)

	if len(ids) != 1 {
		return 0, fmt.Errorf("%w: %s", errInvalidHash, hash)
	}

	return ids[0], nil
}
