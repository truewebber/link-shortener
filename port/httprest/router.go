package httprest

import (
	"net/http"

	"github.com/truewebber/link-shortener/port/httprest/handler"
)

type Router struct {
	linkHandler   *handler.LinkHandler
	healthHandler *handler.HealthHandler
}

func NewRouter(
	linkHandler *handler.LinkHandler,
	healthHandler *handler.HealthHandler,
) *Router {
	return &Router{
		linkHandler:   linkHandler,
		healthHandler: healthHandler,
	}
}

func (r *Router) Handler() http.Handler {
	mux := http.NewServeMux()

	mux.HandleFunc("/health", r.healthHandler.HandleHealth)
	mux.HandleFunc("/api/restricted_urls", r.linkHandler.HandleCreateLink)

	mux.HandleFunc("/", r.linkHandler.HandleRedirect)

	return mux
}
