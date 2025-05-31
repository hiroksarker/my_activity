package migrations

import (
	"github.com/pocketbase/dbx"
	"github.com/pocketbase/pocketbase/daos"
	m "github.com/pocketbase/pocketbase/migrations"
	"github.com/pocketbase/pocketbase/models"
	"github.com/pocketbase/pocketbase/models/schema"
)

func init() {
	m.Register(func(db dbx.Builder) error {
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

		return daos.New(db).SaveCollection(collection)
	}, func(db dbx.Builder) error {
		// Delete the collection if needed
		dao := daos.New(db)
		collection, err := dao.FindCollectionByNameOrId("activities")
		if err != nil {
			return err
		}
		return dao.DeleteCollection(collection)
	})
} 