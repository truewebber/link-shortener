package types

import (
	"errors"
	"fmt"

	userdomain "github.com/truewebber/link-shortener/domain/user"
)

type Provider uint8

const (
	ProviderAnonymous Provider = iota + 1
	ProviderGoogle
	ProviderApple
	ProviderGithub
)

var errUnknownProvider = errors.New("unknown provider")

func BuildProviderFromDomain(provider userdomain.Provider) (Provider, error) {
	switch provider {
	case userdomain.ProviderAnonymous:
		return ProviderAnonymous, nil
	case userdomain.ProviderGoogle:
		return ProviderGoogle, nil
	case userdomain.ProviderApple:
		return ProviderApple, nil
	case userdomain.ProviderGithub:
		return ProviderGithub, nil
	}

	return 0, fmt.Errorf("%w: %v", errUnknownProvider, provider)
}

func BuildProviderToDomain(provider Provider) (userdomain.Provider, error) {
	switch provider {
	case ProviderAnonymous:
		return userdomain.ProviderAnonymous, nil
	case ProviderGoogle:
		return userdomain.ProviderGoogle, nil
	case ProviderApple:
		return userdomain.ProviderApple, nil
	case ProviderGithub:
		return userdomain.ProviderGithub, nil
	}

	return 0, fmt.Errorf("%w: %v", errUnknownProvider, provider)
}
