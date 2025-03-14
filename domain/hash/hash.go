package hash

type Generator interface {
	ToHash(id uint64) (string, error)
	FromHash(hash string) (uint64, error)
}
