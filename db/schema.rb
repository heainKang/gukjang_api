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

ActiveRecord::Schema[8.0].define(version: 2025_11_27_093957) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "alerts", force: :cascade do |t|
    t.string "user_identifier", null: false
    t.string "index_name", null: false
    t.decimal "threshold_value", precision: 10, scale: 2, null: false
    t.string "comparison_type", default: "below", null: false
    t.boolean "is_active", default: true, null: false
    t.text "fcm_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active", "index_name"], name: "index_alerts_on_is_active_and_index_name"
    t.index ["user_identifier", "index_name"], name: "index_alerts_on_user_identifier_and_index_name"
  end

  create_table "indices", force: :cascade do |t|
    t.string "name", null: false
    t.string "symbol", null: false
    t.decimal "current_value", precision: 15, scale: 2
    t.datetime "last_updated"
    t.string "source", default: "yahoo_finance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["last_updated"], name: "index_indices_on_last_updated"
    t.index ["name"], name: "index_indices_on_name", unique: true
    t.index ["symbol"], name: "index_indices_on_symbol", unique: true
  end
end
