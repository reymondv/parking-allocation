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

ActiveRecord::Schema[7.1].define(version: 2024_01_21_145438) do
  create_table "entry_points", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parking_slot_entry_points", force: :cascade do |t|
    t.integer "distance", default: 1
    t.integer "parking_slot_id", null: false
    t.integer "entry_point_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entry_point_id"], name: "index_parking_slot_entry_points_on_entry_point_id"
    t.index ["parking_slot_id"], name: "index_parking_slot_entry_points_on_parking_slot_id"
  end

  create_table "parking_slots", force: :cascade do |t|
    t.string "name", null: false
    t.integer "size", default: 0
    t.boolean "occupied", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "entry_point_id"
    t.index ["entry_point_id"], name: "index_parking_slots_on_entry_point_id"
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "plate_number"
    t.datetime "checkin_time", default: "2024-01-20 15:40:08"
    t.datetime "checkout_time"
    t.integer "parking_slot_id"
    t.integer "total_fee", default: 0
    t.integer "total_hours", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parking_slot_id"], name: "index_vehicles_on_parking_slot_id"
  end

  add_foreign_key "parking_slot_entry_points", "entry_points"
  add_foreign_key "parking_slot_entry_points", "parking_slots"
  add_foreign_key "parking_slots", "entry_points"
  add_foreign_key "vehicles", "parking_slots"
end
