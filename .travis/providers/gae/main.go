package main

import (
	"fmt"
	"net/http"
	"google.golang.org/appengine"
)

func main() {
	http.HandleFunc("/", indexHandler)
	appengine.Main()
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "__ID__")
}
