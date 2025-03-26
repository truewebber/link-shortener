package captcha

import (
	"context"
	"errors"
)

var (
	ErrUnsuccessful  = errors.New("unsuccessful")
	ErrNotHuman      = errors.New("not human")
	ErrActionInvalid = errors.New("action invalid")
)

type Validator interface {
	Validate(ctx context.Context, response string) error
}
