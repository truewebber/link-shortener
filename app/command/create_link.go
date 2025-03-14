package command

import (
	"context"
	"errors"
	"fmt"

	"github.com/truewebber/gopkg/log"
	urlpkg "github.com/truewebber/gopkg/url"

	"github.com/truewebber/link-shortener/domain/hash"
	"github.com/truewebber/link-shortener/domain/link"
)

type CreateLinkParams struct {
	RedirectURL string
	UserID      uint64
	ExpiresType link.ExpiresType
}

type CreateLinkHandler struct {
	linkStorage   link.Storage
	hashGenerator hash.Generator
	logger        log.Logger
}

func NewCreateLinkHandler(
	linkStorage link.Storage,
	hashGenerator hash.Generator,
	logger log.Logger,
) *CreateLinkHandler {
	return &CreateLinkHandler{
		linkStorage:   linkStorage,
		hashGenerator: hashGenerator,
		logger:        logger,
	}
}

var ErrValidation = errors.New("validation")

func (h *CreateLinkHandler) Handle(ctx context.Context, cmd *CreateLinkParams) (string, error) {
	if err := h.validateCreateLinkCommand(cmd); err != nil {
		return "", fmt.Errorf("%w: %w", ErrValidation, err)
	}

	l, err := link.New(cmd.UserID, cmd.RedirectURL, cmd.ExpiresType)
	if err != nil {
		return "", fmt.Errorf("create link: %w", err)
	}

	if createErr := h.linkStorage.Create(ctx, l); createErr != nil {
		return "", fmt.Errorf("create link: %w", createErr)
	}

	linkHash, err := h.hashGenerator.ToHash(l.ID)
	if err != nil {
		return "", fmt.Errorf("generate hash from link id: %w", err)
	}

	return linkHash, nil
}

var errEmptyRedirectURL = errors.New("empty redirect URL")

func (h *CreateLinkHandler) validateCreateLinkCommand(cmd *CreateLinkParams) error {
	if cmd.RedirectURL == "" {
		return errEmptyRedirectURL
	}

	normalizedURL, err := urlpkg.NormalizeWithOptions(cmd.RedirectURL)
	if err != nil {
		return fmt.Errorf("normalize url: %w", err)
	}

	cmd.RedirectURL = normalizedURL.String()

	return nil
}
