package command

import (
	"context"
	"errors"
	"fmt"

	apperrors "github.com/truewebber/link-shortener/app/errors"
	"github.com/truewebber/link-shortener/domain/captcha"
)

type ValidateCaptchaHandler struct {
	validator captcha.Validator
}

func NewValidateCaptchaHandler(
	validator captcha.Validator,
) *ValidateCaptchaHandler {
	return &ValidateCaptchaHandler{
		validator: validator,
	}
}

func (h *ValidateCaptchaHandler) Handle(ctx context.Context, response string) error {
	err := h.validator.Validate(ctx, response)

	if errors.Is(err, captcha.ErrUnsuccessful) ||
		errors.Is(err, captcha.ErrActionInvalid) ||
		errors.Is(err, captcha.ErrNotHuman) {
		return apperrors.ErrCaptchaInvalid
	}

	if err != nil {
		return fmt.Errorf("validate captcha: %w", err)
	}

	return nil
}
