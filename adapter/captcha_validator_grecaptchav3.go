package adapter

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"slices"
	"strings"
	"time"

	"github.com/truewebber/gopkg/log"

	"github.com/truewebber/link-shortener/domain/captcha"
)

type googleCaptchaV3 struct {
	secret         string
	allowedActions []string
	threshold      float32

	httpClient *http.Client
	logger     log.Logger
}

func NewGoogleCaptchaV3Validator(
	secret string,
	allowedActions []string,
	threshold float32,
	logger log.Logger,
) captcha.Validator {
	return &googleCaptchaV3{
		secret:         secret,
		allowedActions: allowedActions,
		threshold:      threshold,
		httpClient:     &http.Client{},
		logger:         logger,
	}
}

func (v *googleCaptchaV3) Validate(ctx context.Context, response string) error {
	siteVerify, err := v.requestValidate(ctx, response)
	if err != nil {
		return fmt.Errorf("validate site verify: %w", err)
	}

	if !siteVerify.Success {
		return captcha.ErrUnsuccessful
	}

	if slices.Contains(v.allowedActions, response) {
		return captcha.ErrActionInvalid
	}

	if v.threshold > siteVerify.Score {
		return captcha.ErrNotHuman
	}

	return nil
}

type siteVerifyResponse struct {
	Success     bool          `json:"success"`
	Score       float32       `json:"score"`
	Action      string        `json:"action"`
	ChallengeTs time.Time     `json:"challenge_ts"`
	Hostname    string        `json:"hostname"`
	ErrorCodes  []interface{} `json:"error-codes"`
}

const verifyURL = "https://www.google.com/recaptcha/api/siteverify"

var errInvalidStatusCode = errors.New("invalid status code")

func (v *googleCaptchaV3) requestValidate(ctx context.Context, response string) (*siteVerifyResponse, error) {
	values := url.Values{}
	values.Set("secret", v.secret)
	values.Set("response", response)

	requestBody := strings.NewReader(values.Encode())

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, verifyURL, requestBody)
	if err != nil {
		return nil, fmt.Errorf("http http request: %w", err)
	}

	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

	resp, err := v.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("do http request: %w", err)
	}

	defer func() {
		if closeErr := resp.Body.Close(); closeErr != nil {
			v.logger.Error("close http response body", "error", closeErr)
		}
	}()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read http response body: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("%w: %s, body: %s", errInvalidStatusCode, resp.Status, string(body))
	}

	siteVerify := &siteVerifyResponse{}

	if unmarshalErr := json.Unmarshal(body, siteVerify); unmarshalErr != nil {
		return nil, fmt.Errorf("unmarshal http response body: %w", unmarshalErr)
	}

	return siteVerify, nil
}
