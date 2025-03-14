package main

import (
	"net/http"
	"syscall"
	"time"

	"github.com/truewebber/gopkg/log"
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
	healthHandler := handler.NewHealthHandler()
	router := httprest.NewRouter(linkHandler, healthHandler)

	logger.Info("starting Link Shortener API server on port %d", cfg.AppHostPort)

	server := newHTTPServer(cfg.AppHostPort)
	server.Handler = router.Handler()

	str := starter.NewStarter()
	str.RegisterServer(starter.WrapHTTP(server))

	shutdownCtx := signal.ContextClosableOnSignals(syscall.SIGINT, syscall.SIGTERM)

	if err := str.StartServers(shutdownCtx); err != nil {
		logger.Error("server error", "error", err)
	}

	logger.Info("server stopped")
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

func newAppConfig(cfg *config) service.Config {
	return service.Config{
		PostgresConnectionString: cfg.PostgresConnectionString,
	}
}
