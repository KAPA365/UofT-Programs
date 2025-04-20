package main

import (
	"log"
	"net/http"
	"pockethealth/internchallenge/pkg/user"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
	"github.com/urfave/negroni"
)

var LISTENING_PORT = "8080"
var ALLOWED_ORIGINS = []string{"http://localhost:4200", "https://localhost:4200", "https://localhost", "https://127.0.0.1:4200", "http://127.0.0.1:4200", "https://127.0.0.1"}
var ALLOWED_HEADERS = []string{"Accept", "Content-type"}
var ALLOWED_METHODS = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
var EXPOSED_HEADERS = []string{"Content-disposition", "cache-control", "content-length", "expires", "pragma"}

func createRouter() *mux.Router {
	// configure auth controller and service to handle requests
	UserApiService := user.NewUserApiService()
	UserApiController := user.NewUserApiController(UserApiService)

	// initialize routes
	mRouter := mux.NewRouter().StrictSlash(false)
	//add paths to subrouter
	for _, route := range UserApiController.Routes() {
		mRouter.
			Methods(route.Method, http.MethodOptions).
			Path(route.Pattern).
			Name(route.Name).
			Handler(route.HandlerFunc)
	}

	return mRouter
}

func main() {
	// configure router
	router := createRouter()

	// configure request handler
	n := negroni.New()
	n.UseHandler(router)

	// CORS config
	handler := handlers.CORS(
		handlers.AllowedOrigins(ALLOWED_ORIGINS),
		handlers.AllowedHeaders(ALLOWED_HEADERS),
		handlers.AllowedMethods(ALLOWED_METHODS),
		handlers.ExposedHeaders(EXPOSED_HEADERS),
	)(n)

	// setup and start the server
	server := &http.Server{Addr: ":" + LISTENING_PORT, Handler: handler}
	log.Println("Listening...")
	err := server.ListenAndServe()
	if err != nil {
		log.Fatal(err)
	}
}
