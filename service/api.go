package service

import (
	"context"

	"github.com/truewebber/gopkg/log"

	"github.com/truewebber/link-shortener/adapter"
	"github.com/truewebber/link-shortener/app"
	"github.com/truewebber/link-shortener/app/command"
	"github.com/truewebber/link-shortener/app/query"
	"github.com/truewebber/link-shortener/app/types"
	userdomain "github.com/truewebber/link-shortener/domain/user"
)

func NewAPIApp(config *Config, logger log.Logger) *app.APIApp {
	pool := adapter.MustNewPgxPool(context.Background(), config.PostgresConnectionString)

	hashGen := adapter.MustNewHashGenerator()
	linkStorage := adapter.NewLinkStoragePgx(pool)
	userStorage := adapter.NewUserStoragePgx(pool)
	tokenStorage := adapter.NewTokenStoragePgx(pool)

	oauthProviders := buildProviders(&config.OAuth, logger)

	return &app.APIApp{
		Command: app.APICommand{
			CreateLink:   command.NewCreateLinkHandler(linkStorage, hashGen, logger),
			FinishOAuth:  command.NewFinishOAuthHandler(userStorage, tokenStorage, oauthProviders, logger),
			RefreshToken: command.NewRefreshTokenHandler(userStorage, tokenStorage),
			Logout:       command.NewLogoutHandler(userStorage, tokenStorage),
		},
		Query: app.APIQuery{
			GetLinkByHash: query.NewGetLinkByHashHandler(linkStorage, hashGen, logger),
			AuthUser:      query.NewAuthUserHandler(userStorage, tokenStorage),
			GetAuthURL:    query.NewGetAuthURLHandler(oauthProviders),
		},
	}
}

func buildProviders(oauthConfig *OAuth, logger log.Logger) map[types.Provider]userdomain.OAuthProvider {
	googleProvider := adapter.NewGoogleOAuthProvider(
		oauthConfig.Google.ClientID,
		oauthConfig.Google.ClientSecret,
		oauthConfig.Google.RedirectURL,
		logger,
	)
	githubProvider := adapter.NewGitHubOAuthProvider(
		oauthConfig.Github.ClientID,
		oauthConfig.Github.ClientSecret,
		oauthConfig.Github.RedirectURL,
		logger,
	)
	appleProvider := adapter.NewAppleOAuthProvider(
		oauthConfig.Apple.ClientID,
		oauthConfig.Apple.RedirectURL,
		oauthConfig.Apple.KeyID,
		oauthConfig.Apple.TeamID,
		oauthConfig.Apple.PrivateKey,
		logger,
	)

	return map[types.Provider]userdomain.OAuthProvider{
		types.ProviderApple:  appleProvider,
		types.ProviderGoogle: googleProvider,
		types.ProviderGithub: githubProvider,
	}
}

type Config struct {
	PostgresConnectionString string
	ServerAddress            string
	BaseURL                  string
	CookieDomain             string
	OAuth                    OAuth
	SecureCookies            bool
}

type OAuth struct {
	Google, Github Standard
	Apple          Apple
}

type Apple struct {
	ClientID, KeyID, TeamID, RedirectURL, PrivateKey string
}

type Standard struct {
	ClientID, ClientSecret, RedirectURL string
}
