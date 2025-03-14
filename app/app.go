package app

import (
	"github.com/truewebber/link-shortener/app/command"
	"github.com/truewebber/link-shortener/app/query"
)

type APIApp struct {
	Command APICommand
	Query   APIQuery
}

type APICommand struct {
	CreateLink *command.CreateLinkHandler
}

type APIQuery struct {
	GetLinkByHash *query.GetLinkByHashHandler
}
