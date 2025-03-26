package main

import (
	"net/http"
	"net/url"
	"strings"
	"syscall"
	"time"

	"github.com/truewebber/gopkg/log"
	"github.com/truewebber/gopkg/metrics"
	"github.com/truewebber/gopkg/signal"
	"github.com/truewebber/gopkg/starter"

	"github.com/truewebber/link-shortener/port/httprest"
	"github.com/truewebber/link-shortener/port/httprest/handler"
	"github.com/truewebber/link-shortener/service"
)

func main() {
	logger := log.NewLogger()

	run(logger)

	if err := logger.Close(); err != nil {
		panic(err)
	}
}

func run(logger log.Logger) {
	cfg := mustLoadConfig()
	appConfig := newAppConfig(cfg)

	app := service.NewAPIApp(appConfig, logger)

	linkHandler := handler.NewLinkHandler(app, cfg.BaseHost, logger)
	authHandler := handler.NewAuthHandler(app, extractDomainFromHost(cfg.BaseHost), logger)
	healthHandler := handler.NewHealthHandler()

	const recorderName = "link-shortener"
	latencyRecorder := metrics.NewLatencyRecorder(recorderName)

	routerHandler := httprest.NewRouterHandler(
		linkHandler,
		authHandler,
		healthHandler,
		latencyRecorder,
		app.Query.AuthUser,
		app.Command.ValidateCaptcha,
		logger,
	)

	logger.Info("starting Link Shortener API server", "address", cfg.AppHostPort)

	server := newHTTPServer(cfg.AppHostPort)
	server.Handler = routerHandler

	logger.Info("starting Metrics server", "address", cfg.MetricsHostPort)

	metricsServer := metrics.NewMetricsServer(cfg.MetricsHostPort)

	str := starter.NewStarter()
	str.RegisterServer(starter.WrapHTTP(server))
	str.RegisterServer(starter.WrapHTTP(metricsServer))

	shutdownCtx := signal.ContextClosableOnSignals(syscall.SIGINT, syscall.SIGTERM)

	if err := str.StartServers(shutdownCtx); err != nil {
		logger.Error("server error", "error", err)
	}

	logger.Info("server stopped")
}

func extractDomainFromHost(host string) string {
	if !strings.Contains(host, ":") {
		return host
	}

	const splintHostAmount = 2
	parts := strings.SplitN(host, ":", splintHostAmount)

	return parts[0]
}

func newHTTPServer(hostPort string) *http.Server {
	const (
		readTimeout  = 5 * time.Second
		writeTimeout = 10 * time.Second
		idleTimeout  = 120 * time.Second
	)

	return &http.Server{
		Addr:         hostPort,
		Handler:      nil,
		ReadTimeout:  readTimeout,
		WriteTimeout: writeTimeout,
		IdleTimeout:  idleTimeout,
	}
}

func newAppConfig(cfg *config) *service.Config {
	const (
		googleCallbackPath = "/api/auth/google/callback"
		githubCallbackPath = "/api/auth/github/callback"
		appleCallbackPath  = "/api/auth/apple/callback"
	)

	const createUnAuthShortURL = "create_unauthorized_short_url"

	return &service.Config{
		PostgresConnectionString: cfg.PostgresConnectionString,
		GoogleCaptchaV3: service.GoogleCaptchaV3{
			Secret:         cfg.GoogleCaptchaSecretKey,
			AllowedActions: []string{createUnAuthShortURL},
			Threshold:      cfg.GoogleCaptchaThreshold,
		},
		OAuth: service.OAuth{
			Google: service.Standard{
				ClientID:     cfg.GoogleClientID,
				ClientSecret: cfg.GoogleClientSecret,
				RedirectURL:  buildCallbackURL(cfg.BaseHost, googleCallbackPath),
			},
			Github: service.Standard{
				ClientID:     cfg.GithubClientID,
				ClientSecret: cfg.GithubClientSecret,
				RedirectURL:  buildCallbackURL(cfg.BaseHost, githubCallbackPath),
			},
			Apple: service.Apple{
				ClientID:    cfg.AppleClientID,
				PrivateKey:  cfg.ApplePrivateKey,
				KeyID:       cfg.AppleKeyID,
				TeamID:      cfg.AppleTeamID,
				RedirectURL: buildCallbackURL(cfg.BaseHost, appleCallbackPath),
			},
		},
	}
}

func buildCallbackURL(baseHost, path string) string {
	const httpsScheme = "https"

	callback := &url.URL{
		Scheme: httpsScheme,
		Host:   baseHost,
		Path:   path,
	}

	return callback.String()
}
