package types

type OAuthResult struct {
	User         *User
	AccessToken  string
	RefreshToken string
}
