# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_01_26_144708) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agencies", force: :cascade do |t|
    t.boolean "active", default: true
    t.text "admin_ids", default: "[]"
    t.decimal "commission_rate", precision: 5, scale: 2, default: "10.0"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "owner_id", null: false
    t.integer "parent_agency_id"
    t.text "settings"
    t.string "subdomain", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_agencies_on_owner_id"
    t.index ["parent_agency_id"], name: "index_agencies_on_parent_agency_id"
    t.index ["subdomain"], name: "index_agencies_on_subdomain", unique: true
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.datetime "created_at", null: false
    t.integer "item_id", null: false
    t.string "item_type", null: false
    t.integer "quantity"
    t.datetime "updated_at", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["item_type", "item_id"], name: "index_cart_items_on_item"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "design_templates", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "diamond_score", default: 50
    t.string "image_url"
    t.boolean "is_featured", default: false
    t.string "mobile_image_url"
    t.string "preview_url"
    t.integer "price", default: 0
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0
  end

  create_table "likes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "design_template_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["design_template_id"], name: "index_likes_on_design_template_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "design_template_id", null: false
    t.integer "order_id", null: false
    t.decimal "price"
    t.integer "quantity"
    t.datetime "updated_at", null: false
    t.index ["design_template_id"], name: "index_order_items_on_design_template_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "agency_id"
    t.integer "amount"
    t.decimal "commission_amount", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.string "customer_name"
    t.string "order_uid"
    t.string "payment_key"
    t.integer "product_id", null: false
    t.string "status"
    t.decimal "total_amount"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["agency_id"], name: "index_orders_on_agency_id"
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "portfolios", force: :cascade do |t|
    t.string "category"
    t.string "client"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "preview_url"
    t.date "project_date"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "name"
    t.integer "price"
    t.integer "stock"
    t.datetime "updated_at", null: false
  end

  create_table "quotes", force: :cascade do |t|
    t.integer "agency_id"
    t.string "budget"
    t.string "company_name"
    t.string "contact_name"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "guest_session_id"
    t.text "message"
    t.string "phone"
    t.string "preferred_domain"
    t.string "project_type"
    t.string "status"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "workflow_status", default: "received"
    t.index ["agency_id"], name: "index_quotes_on_agency_id"
    t.index ["user_id"], name: "index_quotes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "agency_id"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "image"
    t.string "name"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "user"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_users_on_agency_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agencies", "agencies", column: "parent_agency_id"
  add_foreign_key "agencies", "users", column: "owner_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "carts", "users"
  add_foreign_key "likes", "design_templates"
  add_foreign_key "likes", "users"
  add_foreign_key "order_items", "design_templates"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "agencies"
  add_foreign_key "orders", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "quotes", "agencies"
  add_foreign_key "quotes", "users"
  add_foreign_key "users", "agencies"
end
