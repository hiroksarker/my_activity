package main

import (
	"log"
	"os"
	"path/filepath"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
	_ "github.com/hiroksarker/my_activity/pb_migrations" // Import migrations
)

func main() {
	app := pocketbase.New()

	// Serve the admin UI
	app.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		// Serve the admin UI
		adminPath := filepath.Join(os.Getenv("POCKETBASE_DIR"), "pb_migrations")
		e.Router.Static("/admin", adminPath)
		return nil
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
} 