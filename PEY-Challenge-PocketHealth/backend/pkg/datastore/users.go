package datastore

import (
	"context"

	"github.com/google/uuid"
)

// Store users in this map to mimic a db
var userStore = make(map[string]User)

type User struct {
	Id    string
	Name  string
	Email string
	Color string // added new field
}

func CreateUser(ctx context.Context, name string, email string, color string) (string, error) {
	id := uuid.New().String()
	// save the user
	userStore[id] = User{
		Id:    id,
		Name:  name,
		Email: email,
		Color: color, // added new field
	}

	return id, nil
}
