package migrations

import (
	"fmt"
	"log"

	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/daos"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/models"
	"github.com/pocketbase/pocketbase/models/schema"
)

func init() {
	m.Register(func(db dbx.Builder) error {
		log.Println("Starting activities collection migration...")

		// Check if collection already exists
		dao := daos.New(db)
		existing, err := dao.FindCollectionByNameOrId("activities")
		if err == nil && existing != nil {
			log.Println("Collection 'activities' already exists, skipping creation")
			return nil
		}

		// Create activities collection
		collection := &models.Collection{
			Name:       "activities",
			Type:       models.CollectionTypeBase,
			ListRule:   "@request.auth.id != ''",
			ViewRule:   "@request.auth.id != ''",
			CreateRule: "@request.auth.id != ''",
			UpdateRule: "@request.auth.id != ''",
			DeleteRule: "@request.auth.id != ''",
			Schema: schema.NewSchema(
				&schema.SchemaField{
					Name:     "id",
					Type:     schema.FieldTypeText,
					Required: true,
					Unique:   true,
					Options: &schema.TextOptions{
						Max: 15,
					},
					Presentable: true,
					Default:     "{{@random.uuid.substring(0, 15)}}",
				},
				&schema.SchemaField{
					Name:     "title",
					Type:     schema.FieldTypeText,
					Required: true,
				},
				&schema.SchemaField{
					Name:     "description",
					Type:     schema.FieldTypeText,
					Required: false,
				},
				&schema.SchemaField{
					Name:     "date",
					Type:     schema.FieldTypeDate,
					Required: true,
				},
				&schema.SchemaField{
					Name:     "category",
					Type:     schema.FieldTypeText,
					Required: true,
				},
				&schema.SchemaField{
					Name:     "amount",
					Type:     schema.FieldTypeNumber,
					Required: false,
				},
				&schema.SchemaField{
					Name:     "status",
					Type:     schema.FieldTypeText,
					Required: true,
				},
			),
		}

		if err := dao.SaveCollection(collection); err != nil {
			log.Printf("Error creating collection: %v", err)
			return fmt.Errorf("failed to create collection: %w", err)
		}

		log.Println("Successfully created activities collection")
		return nil
	}, func(db dbx.Builder) error {
		log.Println("Starting activities collection rollback...")
		
		dao := daos.New(db)
		collection, err := dao.FindCollectionByNameOrId("activities")
		if err != nil {
			log.Printf("Error finding collection for rollback: %v", err)
			return err
		}

		if err := dao.DeleteCollection(collection); err != nil {
			log.Printf("Error deleting collection during rollback: %v", err)
			return err
		}

		log.Println("Successfully deleted activities collection")
		return nil
	})
} 