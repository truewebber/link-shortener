package httprest

import (
	"net/http"

	"github.com/gorilla/mux"
	"github.com/truewebber/gopkg/log"
	"github.com/truewebber/gopkg/metrics"

	"github.com/truewebber/link-shortener/port/httprest/handler"
	"github.com/truewebber/link-shortener/port/httprest/middleware"
)

func NewRouterHandler(
	linkHandler *handler.LinkHandler,
	healthHandler *handler.HealthHandler,
	latencyRecorder metrics.LatencyRecorder,
	logger log.Logger,
) http.Handler {
	router := mux.NewRouter()

	router.Use(
		middleware.Logging(logger),
		middleware.Metrics(latencyRecorder),
	)

	router.HandleFunc("/health", healthHandler.HandleHealth).Methods(http.MethodGet)
	router.HandleFunc("/api/restricted_urls", linkHandler.HandleCreateLink).Methods(http.MethodPost)

	router.HandleFunc("/{hash:[0-9a-zA-Z]+}", linkHandler.HandleRedirect).Methods(http.MethodGet)

	return router
}
