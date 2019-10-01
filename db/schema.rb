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

ActiveRecord::Schema.define(version: 2019_10_01_214043) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "emojis", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "onaka_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_emojis_on_name", unique: true
    t.index ["onaka_id"], name: "index_emojis_on_onaka_id"
  end

  create_table "onakas", force: :cascade do |t|
    t.string "name", null: false
    t.string "url"
    t.string "custom_display_name"
    t.text "description", default: "", null: false
    t.integer "frequency", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_onakas_on_name", unique: true
  end

  create_table "user_onakas", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "onaka_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["onaka_id"], name: "index_user_onakas_on_onaka_id"
    t.index ["user_id"], name: "index_user_onakas_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "slack_id"
    t.integer "stamina_capacity", default: 60, null: false
    t.integer "last_stamina", default: 60, null: false
    t.datetime "stamina_updated_at", default: "2019-07-01 00:00:00", null: false
    t.integer "score", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "locale", default: "ja", comment: "user preferred locale"
    t.string "name", comment: "Slack display name"
    t.datetime "boosted_stamina_at", comment: "stamina boosted at"
    t.index ["slack_id"], name: "index_users_on_slack_id"
  end

  add_foreign_key "user_onakas", "onakas"
  add_foreign_key "user_onakas", "users"
end
