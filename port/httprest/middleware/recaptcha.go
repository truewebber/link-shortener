package middleware

import (
	"errors"
	"net/http"

	"github.com/truewebber/gopkg/log"

	"github.com/truewebber/link-shortener/app/command"
	apperrors "github.com/truewebber/link-shortener/app/errors"
)

const captchaHeader = "X-Recaptcha-Token"

func ValidateCaptcha(validator *command.ValidateCaptchaHandler, logger log.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			captchaToken := r.Header.Get(captchaHeader)
			if captchaToken == "" {
				logger.Error("captcha header not found")

				w.WriteHeader(http.StatusUnprocessableEntity)

				return
			}

			err := validator.Handle(r.Context(), captchaToken)

			if errors.Is(err, apperrors.ErrCaptchaInvalid) {
				w.WriteHeader(http.StatusUnprocessableEntity)

				return
			}

			if err != nil {
				logger.Error("failed to validate captcha token", "token", captchaToken, "error", err)

				w.WriteHeader(http.StatusInternalServerError)

				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
