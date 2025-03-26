package main

import (
	"fmt"

	"github.com/Netflix/go-env"
)

type config struct {
	GoogleClientID           string  `env:"GOOGLE_CLIENT_ID,required=true"`
	GithubClientID           string  `env:"GITHUB_CLIENT_ID,required=true"`
	BaseHost                 string  `env:"BASE_HOST,required=true"`
	PostgresConnectionString string  `env:"POSTGRES_CONNECTION_STRING,required=true"`
	GoogleCaptchaSecretKey   string  `env:"GOOGLE_CAPTCHA_SECRET_KEY,required=true"`
	GithubClientSecret       string  `env:"GITHUB_CLIENT_SECRET,required=true"`
	AppleClientID            string  `env:"APPLE_CLIENT_ID,required=true"`
	AppHostPort              string  `env:"APP_HOST_PORT,required=true"`
	MetricsHostPort          string  `env:"METRICS_HOST_PORT,required=true"`
	ApplePrivateKey          string  `env:"APPLE_PRIVATE_KEY,required=true"`
	AppleKeyID               string  `env:"APPLE_KEY_ID,required=true"`
	AppleTeamID              string  `env:"APPLE_TEAM_ID,required=true"`
	GoogleClientSecret       string  `env:"GOOGLE_CLIENT_SECRET,required=true"`
	GoogleCaptchaThreshold   float32 `env:"GOOGLE_CAPTCHA_THRESHOLD,required=true"`
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
