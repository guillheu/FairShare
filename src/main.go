package main

import (
	"fmt"

	"github.com/guillheu/FairShare/src/ingest/config"
)

func main() {
	configInstance := config.GetConfig()
	fmt.Print(configInstance)
}
