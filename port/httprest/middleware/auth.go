package middleware

import (
	"context"
	"errors"
	"net/http"
	"strings"

	"github.com/truewebber/gopkg/log"

	apperrors "github.com/truewebber/link-shortener/app/errors"
	"github.com/truewebber/link-shortener/app/query"
	httpcontext "github.com/truewebber/link-shortener/port/httprest/context"
)

func Auth(authUser *query.AuthUserHandler, logger log.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			token := extractToken(r)
			if token == "" {
				http.Error(w, "authorization required", http.StatusUnauthorized)

				return
			}

			user, err := authUser.Handle(r.Context(), token)
			if errors.Is(err, apperrors.ErrInvalidCredentials) ||
				errors.Is(err, apperrors.ErrTokenExpired) ||
				errors.Is(err, apperrors.ErrUserNotFound) {
				http.Error(w, "Invalid or expired token", http.StatusUnauthorized)

				return
			}

			if err != nil {
				logger.Error("access token verification failed", "token", token, "error", err)

				http.Error(w, "internal", http.StatusInternalServerError)

				return
			}

			outboundCtx := context.WithValue(r.Context(), httpcontext.KeyUser, user)
			outboundCtx = context.WithValue(outboundCtx, httpcontext.KeyToken, token)

			next.ServeHTTP(w, r.WithContext(outboundCtx))
		})
	}
}

func OptionalAuth(authUser *query.AuthUserHandler, logger log.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			outboundCtx := r.Context()

			token := extractToken(r)
			if token == "" {
				next.ServeHTTP(w, r)

				return
			}

			outboundCtx = context.WithValue(outboundCtx, httpcontext.KeyToken, token)

			user, err := authUser.Handle(r.Context(), token)
			if err != nil {
				if !errors.Is(err, apperrors.ErrInvalidCredentials) &&
					!errors.Is(err, apperrors.ErrTokenExpired) &&
					!errors.Is(err, apperrors.ErrUserNotFound) {
					logger.Error("access token verification failed", "token", token, "error", err)
				}

				next.ServeHTTP(w, r.WithContext(outboundCtx))

				return
			}

			outboundCtx = context.WithValue(outboundCtx, httpcontext.KeyUser, user)

			next.ServeHTTP(w, r.WithContext(outboundCtx))
		})
	}
}

const (
	tokenPartsCount     = 2
	authorizationHeader = "Authorization"
	tokenPrefix         = "Bearer"
)

func extractToken(r *http.Request) string {
	authHeader := r.Header.Get(authorizationHeader)
	if authHeader == "" {
		return ""
	}

	parts := strings.SplitN(authHeader, " ", tokenPartsCount)
	if len(parts) != tokenPartsCount || parts[0] != tokenPrefix {
		return ""
	}

	return parts[1]
}
