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

	return &app.APIApp{
		Command: app.APICommand{
			CreateLink: command.NewCreateLinkHandler(linkStorage, hashGen, logger),
		},
		Query: app.APIQuery{
			GetLinkByHash: query.NewGetLinkByHashHandler(linkStorage, hashGen, logger),
		},
	}
}

type Config struct {
	PostgresConnectionString string
}
