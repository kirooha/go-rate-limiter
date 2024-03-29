package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
)

type User struct {
	Name    string `json:"name"`
	Address string `json:"address"`
}

type FooHandler struct {
}

func (h *FooHandler) ServeHTTP(writer http.ResponseWriter, request *http.Request) {
	var (
		msgPrefix = "FooHandler.ServeHTTP"
		user      User
	)

	log.Printf("%s: request received\n", msgPrefix)

	if request.Method != http.MethodPost {
		writer.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	// 500KB
	request.Body = http.MaxBytesReader(writer, request.Body, 512000)

	b, err := io.ReadAll(request.Body)
	if err != nil {
		log.Printf("%s: io.ReadAll error %v\n", msgPrefix, err)

		maxBytesError := &http.MaxBytesError{}
		if errors.As(err, &maxBytesError) {
			writer.WriteHeader(http.StatusBadRequest)
			return
		}

		writer.WriteHeader(http.StatusInternalServerError)
		return
	}

	if err := json.Unmarshal(b, &user); err != nil {
		log.Printf("%s: json.Unmarshal error %v\n", msgPrefix, err)
		writer.WriteHeader(http.StatusBadRequest)
		return
	}

	_, err = fmt.Fprintf(writer, "Hello %s, this is /foo handler\n", user.Name)
	if err != nil {
		log.Println(err)
	}
}

type BarHandler struct {
}

func (h *BarHandler) ServeHTTP(writer http.ResponseWriter, request *http.Request) {
	var (
		msgPrefix = "BarHandler.ServeHTTP"
	)

	log.Printf("%s: request received\n", msgPrefix)

	if request.Method != http.MethodGet {
		writer.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	_, err := fmt.Fprint(writer, "response from /bar handler\n")
	if err != nil {
		log.Println(err)
	}
}

func main() {
	var (
		fooHandler = &FooHandler{}
		barHandler = &BarHandler{}
	)

	mux := http.NewServeMux()
	mux.Handle("/foo", fooHandler)
	mux.Handle("/bar", barHandler)

	log.Println("http server is starting on 9080")
	log.Fatal(http.ListenAndServe(":9080", mux))
}
