package query

import (
	"context"
	"errors"
	"fmt"

	"github.com/truewebber/gopkg/log"

	"github.com/truewebber/link-shortener/domain/hash"
	"github.com/truewebber/link-shortener/domain/link"
)

type GetLinkByHashParams struct {
	Hash string
}

type GetLinkByHashHandler struct {
	linkStorage link.Storage
	hashGen     hash.Generator
	logger      log.Logger
}

func NewGetLinkByHashHandler(
	linkStorage link.Storage,
	hashGen hash.Generator,
	logger log.Logger,
) *GetLinkByHashHandler {
	return &GetLinkByHashHandler{
		linkStorage: linkStorage,
		hashGen:     hashGen,
		logger:      logger,
	}
}

var ErrNotFound = errors.New("not found")

func (h *GetLinkByHashHandler) Handle(ctx context.Context, params GetLinkByHashParams) (*link.Link, error) {
	id, err := h.hashGen.FromHash(params.Hash)
	if err != nil {
		return nil, fmt.Errorf("failed to decode hash: %w", err)
	}

	l, err := h.linkStorage.ByID(ctx, id)

	if errors.Is(err, link.ErrNotFound) {
		return nil, ErrNotFound
	}

	if err != nil {
		return nil, fmt.Errorf("failed to get link: %w", err)
	}

	return l, nil
}
