package middleware

import (
	"net/http"
	"time"

	"github.com/gorilla/mux"
	"github.com/truewebber/gopkg/log"
)

func Logging(logger log.Logger) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()
			rw := newResponseWriter(w)

			next.ServeHTTP(rw, r)

			logger.Info(
				"new request",
				"method", r.Method,
				"endpoint", r.URL.String(),
				"status_code", rw.StatusCode,
				"body_bytes", rw.Size,
				"user_agent", r.UserAgent(),
				"http_referer", r.Referer(),
				"remote_addr", r.RemoteAddr,
				"duration_seconds", time.Since(start).Seconds(),
			)
		})
	}
}
