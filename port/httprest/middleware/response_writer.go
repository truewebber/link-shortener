package middleware

import "net/http"

type responseWriter struct {
	w          http.ResponseWriter
	StatusCode int
	Size       int
}

func newResponseWriter(w http.ResponseWriter) *responseWriter {
	return &responseWriter{w, http.StatusOK, 0}
}

func (rw *responseWriter) Header() http.Header {
	return rw.w.Header()
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.StatusCode = code
	rw.w.WriteHeader(code)
}

func (rw *responseWriter) Write(b []byte) (int, error) {
	size, err := rw.w.Write(b)
	rw.Size += size

	//nolint:wrapcheck // fallthrough error without wrapping
	return size, err
}
