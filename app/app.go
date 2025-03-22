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
	CreateLink   *command.CreateLinkHandler
	FinishOAuth  *command.FinishOAuthHandler
	Logout       *command.LogoutHandler
	RefreshToken *command.RefreshTokenHandler
}

type APIQuery struct {
	GetLinkByHash *query.GetLinkByHashHandler
	AuthUser      *query.AuthUserHandler
	GetAuthURL    *query.GetAuthURLHandler
}
