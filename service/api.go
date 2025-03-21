package service

import (
	"context"

	"github.com/truewebber/gopkg/log"

	"github.com/truewebber/link-shortener/adapter"
	"github.com/truewebber/link-shortener/app"
	"github.com/truewebber/link-shortener/app/command"
	"github.com/truewebber/link-shortener/app/query"
)

func NewAPIApp(config Config, logger log.Logger) *app.APIApp {
	pool := adapter.MustNewPgxPool(context.Background(), config.PostgresConnectionString)

	hashGen := adapter.MustNewHashGenerator()
	linkStorage := adapter.NewLinkStoragePgx(pool)
	userStorage := adapter.NewUserStoragePgx(pool)
	tokenStorage := adapter.NewTokenStoragePgx(pool)

	return &app.APIApp{
		Command: app.APICommand{
			CreateLink:   command.NewCreateLinkHandler(linkStorage, hashGen, logger),
			SignUp:       command.NewSignUpHandler(userStorage, tokenStorage),
			RefreshToken: command.NewRefreshTokenHandler(userStorage, tokenStorage),
			Logout:       command.NewLogoutHandler(userStorage, tokenStorage),
		},
		Query: app.APIQuery{
			GetLinkByHash: query.NewGetLinkByHashHandler(linkStorage, hashGen, logger),
			AuthUser:      query.NewAuthUserHandler(userStorage, tokenStorage),
		},
	}
}

type Config struct {
	PostgresConnectionString string

	// OAuth settings
	GoogleClientID     string
	GoogleClientSecret string
	AppleClientID      string
	AppleClientSecret  string
	GithubClientID     string
	GithubClientSecret string
	OAuthRedirectURL   string

	// JWT settings
	JWTSecret string
}
