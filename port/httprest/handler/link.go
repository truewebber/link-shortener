package handler

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"

	"github.com/gorilla/mux"
	"github.com/truewebber/gopkg/log"

	"github.com/truewebber/link-shortener/app"
	"github.com/truewebber/link-shortener/app/command"
	"github.com/truewebber/link-shortener/app/query"
	apptypes "github.com/truewebber/link-shortener/app/types"
	"github.com/truewebber/link-shortener/domain/link"
	"github.com/truewebber/link-shortener/port/httprest/context"
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
	TTL string `json:"ttl"`
}

type CreateLinkResponse struct {
	ShortURL string `json:"short_url"`
}

func (h *LinkHandler) CreateAnonymousLink(w http.ResponseWriter, r *http.Request) {
	var req CreateLinkRequest

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		h.logger.Error("failed to decode request", "error", err)
		http.Error(w, "invalid request", http.StatusBadRequest)

		return
	}

	params := &command.CreateLinkParams{
		UserID:      apptypes.AnonymousUser().ID,
		RedirectURL: req.URL,
		ExpiresType: link.ExpiresType3Months,
	}

	hash, err := h.app.Command.CreateLink.Handle(r.Context(), params)
	if err != nil {
		h.logger.Error("failed to create link", "params", params, "error", err)
		http.Error(w, "internal", http.StatusInternalServerError)

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

func (h *LinkHandler) CreateLink(w http.ResponseWriter, r *http.Request) {
	user, ok := r.Context().Value(context.KeyUser).(*apptypes.User)
	if !ok {
		http.Error(w, "authorization required", http.StatusUnauthorized)

		return
	}

	req := &CreateLinkRequest{}

	if err := json.NewDecoder(r.Body).Decode(req); err != nil {
		h.logger.Error("failed to decode request", "error", err)
		http.Error(w, "invalid request", http.StatusBadRequest)

		return
	}

	params, err := h.buildCreateLinkParams(req, user)
	if err != nil {
		h.logger.Error("failed to build create link params", "error", err)
		http.Error(w, "invalid request", http.StatusBadRequest)

		return
	}

	hash, err := h.app.Command.CreateLink.Handle(r.Context(), params)
	if err != nil {
		h.logger.Error("failed to create link", "params", params, "error", err)
		http.Error(w, "internal", http.StatusInternalServerError)

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

func (h *LinkHandler) Redirect(w http.ResponseWriter, r *http.Request) {
	pathVars := mux.Vars(r)
	hash, ok := pathVars["hash"]

	if !ok || hash == "" {
		h.logger.Error("invalid hash", "hash", hash, "path", r.URL.Path)
		http.Error(w, "bad request", http.StatusBadRequest)

		return
	}

	params := query.GetLinkByHashParams{
		Hash: hash,
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
		Path:   "/" + hash,
	}
}

const (
	linkExpiresType3Months  = "3months"
	linkExpiresType6Months  = "6months"
	linkExpiresType12Months = "12months"
	linkExpiresTypeNever    = "never"
)

var errUnknownLinkExpiresType = errors.New("unknown link expires type")

func (h *LinkHandler) buildExpiresType(ttl string) (link.ExpiresType, error) {
	switch ttl {
	case linkExpiresType3Months:
		return link.ExpiresType3Months, nil
	case linkExpiresType6Months:
		return link.ExpiresType6Months, nil
	case linkExpiresType12Months:
		return link.ExpiresType12Months, nil
	case linkExpiresTypeNever:
		return link.ExpiresTypeNever, nil
	}

	return 0, errUnknownLinkExpiresType
}

func (h *LinkHandler) buildCreateLinkParams(
	req *CreateLinkRequest, user *apptypes.User,
) (*command.CreateLinkParams, error) {
	expiresType, err := h.buildExpiresType(req.TTL)
	if err != nil {
		return nil, fmt.Errorf("build link expires type: %w", err)
	}

	return &command.CreateLinkParams{
		UserID:      user.ID,
		RedirectURL: req.URL,
		ExpiresType: expiresType,
	}, nil
}
