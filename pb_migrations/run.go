package main

import (
	"log"
	"os"
	"path/filepath"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/plugins/migratecmd"
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

	// Add migrate command with auto-migration enabled
	migratecmd.MustRegister(app, app.RootCmd, migratecmd.Config{
		Automigrate: true,
		Dir:         "migrations",
	})

	// Start the server
	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
} 