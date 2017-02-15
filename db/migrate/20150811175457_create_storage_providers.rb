class CreateStorageProviders < ActiveRecord::Migration
  def change
    create_table :storage_providers, id: :uuid do |t|
      t.string :display_name
      t.string :description
      t.string :name
      t.string :url_root
      t.string :provider_version
      t.string :auth_uri
      t.string :service_user
      t.string :service_pass
      t.string :primary_key
      t.string :secondary_key
      t.string :storage_type
      t.string :endpoint
      t.string :region
      t.string :access_key
      t.string :secret_access_key
      t.boolean :is_deprecated, null: false, default: false

      t.timestamps null: false
    end
  end
end
