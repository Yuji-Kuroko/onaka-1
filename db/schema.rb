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

ActiveRecord::Schema.define(version: 2019_07_28_194801) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "emojis", force: :cascade do |t|
    t.string "name", null: false
    t.string "url"
    t.string "custom_display_name"
    t.text "description", default: "", null: false
    t.integer "frequency", default: 0, null: false
    t.boolean "available", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_emojis_on_name", unique: true
  end

  create_table "user_emojis", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "emoji_id"
    t.integer "count", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["emoji_id"], name: "index_user_emojis_on_emoji_id"
    t.index ["user_id"], name: "index_user_emojis_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.integer "stamina_capacity", default: 60, null: false
    t.integer "last_stamina", default: 60, null: false
    t.datetime "stamina_updated_at", default: "2019-07-01 00:00:00", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "user_emojis", "emojis"
  add_foreign_key "user_emojis", "users"
end
