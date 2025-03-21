package main

import (
	"fmt"

	"github.com/Netflix/go-env"
)

type config struct {
	AppHostPort              string `env:"APP_HOST_PORT,required=true"`
	MetricsHostPort          string `env:"METRICS_HOST_PORT,required=true"`
	BaseHost                 string `env:"BASE_HOST,required=true"`
	PostgresConnectionString string `env:"POSTGRES_CONNECTION_STRING,required=true"`

	// OAuth settings
	GoogleClientID     string `env:"GOOGLE_CLIENT_ID"`
	GoogleClientSecret string `env:"GOOGLE_CLIENT_SECRET"`
	AppleClientID      string `env:"APPLE_CLIENT_ID"`
	AppleClientSecret  string `env:"APPLE_CLIENT_SECRET"`
	GithubClientID     string `env:"GITHUB_CLIENT_ID"`
	GithubClientSecret string `env:"GITHUB_CLIENT_SECRET"`
	OAuthRedirectURL   string `env:"OAUTH_REDIRECT_URL"`

	// JWT settings
	JWTSecret string `env:"JWT_SECRET,required=true"`
}

func mustLoadConfig() *config {
	cfg, err := loadConfig()
	if err != nil {
		panic(err)
	}

	return cfg
}

func loadConfig() (*config, error) {
	c := &config{}

	if _, err := env.UnmarshalFromEnviron(c); err != nil {
		return nil, fmt.Errorf("config unmarshal: %w", err)
	}

	return c, nil
}
