package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/truewebber/gopkg/log"

	"github.com/truewebber/link-shortener/app/query"
)

// Auth is a middleware that checks for a valid authentication token
func Auth(authUser *query.AuthUserHandler, logger log.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Extract token from Authorization header
			token := extractToken(r)
			if token == "" {
				http.Error(w, "Authorization required", http.StatusUnauthorized)
				return
			}

			// Verify token and get the user
			user, err := authUser.Handle(r.Context(), token)
			if err != nil {
				logger.Error("Token verification failed: " + err.Error())
				http.Error(w, "Invalid or expired token", http.StatusUnauthorized)
				return
			}

			ctx := context.WithValue(r.Context(), "user", user)
			ctx = context.WithValue(ctx, "access_token", token)

			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

// OptionalAuth is a middleware that adds user to context if auth is provided but continues chain anyway
func OptionalAuth(authUser *query.AuthUserHandler, logger log.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			// Extract token from Authorization header
			token := extractToken(r)
			if token != "" {
				// Verify token and get the user
				user, err := authUser.Handle(r.Context(), token)
				if err != nil {
					// Log the error but continue without user in context
					logger.Error("Token verification failed", "token", token, "error", err)
				}

				ctx := context.WithValue(r.Context(), "user", user)
				ctx = context.WithValue(ctx, "access_token", token)

				next.ServeHTTP(w, r.WithContext(ctx))
				return
			}

			// Continue without user context
			next.ServeHTTP(w, r)
		})
	}
}

// Extract token from Authorization header
func extractToken(r *http.Request) string {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		return ""
	}

	// Check the format is "Bearer <token>"
	parts := strings.SplitN(authHeader, " ", 2)
	if len(parts) != 2 || parts[0] != "Bearer" {
		return ""
	}

	return parts[1]
}
