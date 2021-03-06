# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170622204323) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "activities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.uuid     "creator_id"
    t.datetime "started_on"
    t.datetime "ended_on"
    t.boolean  "is_deleted",  default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "affiliations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "project_id"
    t.uuid     "user_id"
    t.string   "project_role_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "api_keys", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "user_id"
    t.uuid     "software_agent_id"
    t.string   "key"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "audits", force: :cascade do |t|
    t.uuid     "auditable_id"
    t.string   "auditable_type"
    t.uuid     "associated_id"
    t.string   "associated_type"
    t.uuid     "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.jsonb    "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index", using: :btree
    t.index ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
    t.index ["comment"], name: "index_audits_on_comment", using: :gin
    t.index ["created_at"], name: "index_audits_on_created_at", using: :btree
    t.index ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
    t.index ["user_id", "user_type"], name: "user_index", using: :btree
  end

  create_table "auth_roles", id: false, force: :cascade do |t|
    t.string   "id",                            null: false
    t.string   "name"
    t.string   "description"
    t.jsonb    "permissions"
    t.jsonb    "contexts"
    t.boolean  "is_deprecated", default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["contexts"], name: "index_auth_roles_on_contexts", using: :gin
    t.index ["permissions"], name: "index_auth_roles_on_permissions", using: :gin
  end

  create_table "authentication_services", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "service_id"
    t.string   "base_uri"
    t.string   "name"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "type"
    t.string   "client_id"
    t.string   "client_secret"
    t.boolean  "is_default",           default: false, null: false
    t.string   "login_initiation_uri"
    t.string   "login_response_type"
    t.boolean  "is_deprecated",        default: false, null: false
    t.integer  "identity_provider_id"
  end

  create_table "chunks", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "upload_id"
    t.integer  "number"
    t.integer  "size"
    t.string   "fingerprint_value"
    t.string   "fingerprint_algorithm"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "containers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.string   "type"
    t.uuid     "parent_id"
    t.uuid     "project_id"
    t.boolean  "is_deleted", default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "label"
  end

  create_table "file_versions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "data_file_id"
    t.integer  "version_number"
    t.string   "label"
    t.uuid     "upload_id"
    t.boolean  "is_deleted",     default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "fingerprints", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "upload_id"
    t.string   "algorithm"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "identity_providers", force: :cascade do |t|
    t.string   "host"
    t.string   "port"
    t.string   "type"
    t.string   "ldap_base"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "job_transactions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "transactionable_type"
    t.uuid     "transactionable_id"
    t.string   "request_id"
    t.string   "key"
    t.string   "state"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "meta_properties", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "meta_template_id"
    t.uuid     "property_id"
    t.string   "value"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "meta_templates", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "templatable_id"
    t.string   "templatable_type"
    t.uuid     "template_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "project_permissions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "project_id"
    t.uuid     "user_id"
    t.string   "auth_role_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "project_roles", id: false, force: :cascade do |t|
    t.string   "id",                            null: false
    t.string   "name"
    t.string   "description"
    t.boolean  "is_deprecated", default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "project_transfer_users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "project_transfer_id"
    t.uuid     "to_user_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "project_transfers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.integer  "status"
    t.text     "status_comment"
    t.uuid     "project_id"
    t.uuid     "from_user_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "projects", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.uuid     "creator_id"
    t.string   "etag"
    t.boolean  "is_deleted",    default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "is_consistent"
  end

  create_table "properties", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "template_id"
    t.string   "key"
    t.string   "label"
    t.text     "description"
    t.string   "data_type"
    t.boolean  "is_deprecated"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "prov_relations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "type"
    t.uuid     "creator_id"
    t.uuid     "relatable_from_id"
    t.string   "relatable_from_type"
    t.string   "relationship_type"
    t.uuid     "relatable_to_id"
    t.string   "relatable_to_type"
    t.boolean  "is_deleted",          default: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["relatable_from_id"], name: "index_prov_relations_on_relatable_from_id", using: :btree
    t.index ["relatable_to_id"], name: "index_prov_relations_on_relatable_to_id", using: :btree
  end

  create_table "software_agents", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.uuid     "creator_id"
    t.string   "repo_url"
    t.boolean  "is_deleted",  default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "storage_providers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "display_name"
    t.string   "description"
    t.string   "name"
    t.string   "url_root"
    t.string   "provider_version"
    t.string   "auth_uri"
    t.string   "service_user"
    t.string   "service_pass"
    t.string   "primary_key"
    t.string   "secondary_key"
    t.boolean  "is_deprecated",        default: false, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "chunk_hash_algorithm", default: "md5"
  end

  create_table "system_permissions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "user_id"
    t.string   "auth_role_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "tags", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "label"
    t.string   "taggable_type"
    t.uuid     "taggable_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "templates", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.string   "label"
    t.text     "description"
    t.boolean  "is_deprecated", default: false
    t.uuid     "creator_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "uploads", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "project_id"
    t.string   "name"
    t.string   "content_type"
    t.bigint   "size"
    t.string   "fingerprint_value"
    t.string   "fingerprint_algorithm"
    t.uuid     "storage_provider_id"
    t.datetime "error_at"
    t.string   "error_message"
    t.datetime "completed_at"
    t.string   "etag"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.uuid     "creator_id"
    t.boolean  "is_consistent"
  end

  create_table "user_authentication_services", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "user_id"
    t.uuid     "authentication_service_id"
    t.string   "uid"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "username"
    t.string   "etag"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "display_name"
    t.datetime "last_login_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

end
