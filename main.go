package main

import (
	"fmt"

	"github.com/gopherjs/gopherjs/js"
)

type elmInit struct {
	node *js.Object
}

func main() {
	args := elmInit{}

	args.node = js.Global.Get("document").Call("getElementById", "app")

	elm := js.Global.Get("Elm").Get("Main").Call("init", args)

	fmt.Println(elm)
}
