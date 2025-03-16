package middleware

import (
	"net/http"
	"time"

	"github.com/gorilla/mux"
	"github.com/truewebber/gopkg/metrics"
)

func Metrics(recorder metrics.LatencyRecorder) mux.MiddlewareFunc {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()
			rw := newResponseWriter(w)

			next.ServeHTTP(rw, r)

			recorder.RecordLatency(metrics.Labels{
				Method:     r.Method,
				Path:       extractPathTemplate(r),
				StatusCode: rw.StatusCode,
			}, start)
		})
	}
}

func extractPathTemplate(r *http.Request) string {
	route := mux.CurrentRoute(r)
	if route == nil {
		return r.URL.Path
	}

	routePath, err := route.GetPathTemplate()
	if err != nil {
		return r.URL.Path
	}

	return routePath
}
