package types

type Auth struct {
	User         *User
	AccessToken  string
	RefreshToken string
}
