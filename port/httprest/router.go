package httprest

import (
	"github.com/truewebber/link-shortener/app/query"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/truewebber/gopkg/log"
	"github.com/truewebber/gopkg/metrics"

	"github.com/truewebber/link-shortener/port/httprest/handler"
	"github.com/truewebber/link-shortener/port/httprest/middleware"
)

func NewRouterHandler(
	linkHandler *handler.LinkHandler,
	authHandler *handler.AuthHandler,
	healthHandler *handler.HealthHandler,
	latencyRecorder metrics.LatencyRecorder,
	authUser *query.AuthUserHandler,
	logger log.Logger,
) http.Handler {
	router := mux.NewRouter()

	router.Use(
		middleware.Logging(logger),
		middleware.Metrics(latencyRecorder),
	)

	// Public health check endpoint
	router.HandleFunc("/health", healthHandler.HandleHealth).Methods(http.MethodGet)

	// Public auth endpoints
	router.HandleFunc("/api/auth/oauth", authHandler.HandleOAuth).Methods(http.MethodPost)
	router.HandleFunc("/api/auth/refresh", authHandler.HandleRefreshToken).Methods(http.MethodPost)

	// Protected auth endpoints
	authRouter := router.PathPrefix("/api/auth").Subrouter()
	authRouter.Use(middleware.Auth(authUser, logger))
	authRouter.HandleFunc("/logout", authHandler.HandleLogout).Methods(http.MethodPost)
	authRouter.HandleFunc("/me", authHandler.HandleMe).Methods(http.MethodGet)

	// API endpoints with optional authentication
	apiRouter := router.PathPrefix("/api").Subrouter()
	apiRouter.Use(middleware.OptionalAuth(authUser, logger))

	// URL shortening endpoint
	// TODO: is it valid to register urls with crossed paths on different sub routers?
	router.HandleFunc("/api/restricted_urls", linkHandler.HandleCreateLink).Methods(http.MethodPost)

	// Redirect handler for shortened URLs
	router.HandleFunc("/{hash:[0-9a-zA-Z]+}", linkHandler.HandleRedirect).Methods(http.MethodGet)

	return router
}
