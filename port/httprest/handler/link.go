package handler

import (
	"encoding/json"
	"net/http"
	"net/url"
	"strings"

	"github.com/truewebber/gopkg/log"

	"github.com/truewebber/link-shortener/app"
	"github.com/truewebber/link-shortener/app/command"
	"github.com/truewebber/link-shortener/app/query"
	"github.com/truewebber/link-shortener/domain/link"
	"github.com/truewebber/link-shortener/domain/user"
)

type LinkHandler struct {
	logger   log.Logger
	app      *app.APIApp
	baseHost string
}

func NewLinkHandler(
	app *app.APIApp,
	baseHost string,
	logger log.Logger,
) *LinkHandler {
	return &LinkHandler{
		app:      app,
		baseHost: baseHost,
		logger:   logger,
	}
}

type CreateLinkRequest struct {
	URL string `json:"url"`
}

type CreateLinkResponse struct {
	ShortURL string `json:"short_url"`
}

func (h *LinkHandler) HandleCreateLink(w http.ResponseWriter, r *http.Request) {
	var req CreateLinkRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.logger.Error("failed to decode request", "error", err)
		http.Error(w, "invalid request", http.StatusBadRequest)

		return
	}

	params := &command.CreateLinkParams{
		UserID:      user.AnonymousUser().ID,
		RedirectURL: req.URL,
		ExpiresType: link.ExpiresType3Months,
	}

	hash, err := h.app.Command.CreateLink.Handle(r.Context(), params)
	if err != nil {
		h.logger.Error("failed to create link", "params", params, "error", err)
		http.Error(w, "create link", http.StatusInternalServerError)

		return
	}

	resp := CreateLinkResponse{
		ShortURL: h.buildShortenURL(hash).String(),
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)

	if encodeErr := json.NewEncoder(w).Encode(resp); encodeErr != nil {
		h.logger.Error("failed to encode response", "response", resp, "error", encodeErr)
		http.Error(w, "internal", http.StatusInternalServerError)

		return
	}
}

func (h *LinkHandler) HandleRedirect(w http.ResponseWriter, r *http.Request) {
	path := strings.TrimPrefix(r.URL.Path, "/")
	if path == "" {
		h.logger.Error("invalid path", "path", path)
		http.Error(w, "invalid URL", http.StatusBadRequest)

		return
	}

	params := query.GetLinkByHashParams{
		Hash: path,
	}

	l, err := h.app.Query.GetLinkByHash.Handle(r.Context(), params)
	if err != nil {
		h.logger.Error("failed to get link", "params", params, "error", err)
		http.Error(w, "not found or expired", http.StatusNotFound)

		return
	}

	http.Redirect(w, r, l.RedirectURL, http.StatusFound)
}

const schemeHTTPS = "https"

func (h *LinkHandler) buildShortenURL(hash string) *url.URL {
	return &url.URL{
		Scheme: schemeHTTPS,
		Host:   h.baseHost,
		Path:   "" + hash,
	}
}
