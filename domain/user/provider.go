package user

type Provider uint8

const (
	ProviderAnonymous Provider = iota + 1
	ProviderGoogle
	ProviderApple
	ProviderGithub
)
