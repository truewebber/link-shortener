package httprest

import (
	"net/http"

	"github.com/gorilla/mux"
	"github.com/truewebber/gopkg/log"
	"github.com/truewebber/gopkg/metrics"

	"github.com/truewebber/link-shortener/app/command"
	"github.com/truewebber/link-shortener/app/query"
	"github.com/truewebber/link-shortener/port/httprest/handler"
	"github.com/truewebber/link-shortener/port/httprest/middleware"
)

func NewRouterHandler(
	linkHandler *handler.LinkHandler,
	authHandler *handler.AuthHandler,
	healthHandler *handler.HealthHandler,
	latencyRecorder metrics.LatencyRecorder,
	authUser *query.AuthUserHandler,
	validateCaptcha *command.ValidateCaptchaHandler,
	logger log.Logger,
) http.Handler {
	router := mux.NewRouter()

	router.Use(
		middleware.Logging(logger),
		middleware.Metrics(latencyRecorder),
	)

	// Public health check endpoint
	router.HandleFunc("/health", healthHandler.Health).Methods(http.MethodGet)

	// Public auth endpoint
	router.HandleFunc("/api/auth/refresh", authHandler.RefreshToken).Methods(http.MethodPost)

	// OAuth provider endpoints
	router.HandleFunc(
		"/api/auth/{provider:(?:google|apple|github)}",
		authHandler.StartOAuth,
	).Methods(http.MethodGet)
	router.HandleFunc(
		"/api/auth/{provider:(?:google|apple|github)}/callback",
		authHandler.OAuthCallback,
	)

	// Protected auth endpoints
	authRouter := router.PathPrefix("/api").Subrouter()
	authRouter.Use(middleware.Auth(authUser, logger))
	authRouter.HandleFunc("/auth/logout", authHandler.Logout).Methods(http.MethodPost)
	authRouter.HandleFunc("/auth/me", authHandler.Me).Methods(http.MethodGet)

	authRouter.HandleFunc("/urls", linkHandler.CreateLink).Methods(http.MethodPost)

	// URL shortening endpoint for public usage
	captchaRouter := router.NewRoute().Subrouter()
	captchaRouter.Use(middleware.ValidateCaptcha(validateCaptcha, logger))
	captchaRouter.HandleFunc("/api/restricted_urls", linkHandler.CreateAnonymousLink).Methods(http.MethodPost)

	// Redirect handler for shortened URLs
	router.HandleFunc("/{hash:[0-9a-zA-Z]+}", linkHandler.Redirect).Methods(http.MethodGet)

	return router
}
