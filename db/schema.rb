# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140818042135) do

  create_table "movies", force: true do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "tomatometer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "request_theaters", force: true do |t|
    t.integer  "request_id"
    t.integer  "theater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "request_theaters", ["request_id"], name: "index_request_theaters_on_request_id"
  add_index "request_theaters", ["theater_id"], name: "index_request_theaters_on_theater_id"

  create_table "requests", force: true do |t|
    t.integer  "radius"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "query_address"
    t.string   "formatted_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zip_code"
  end

  create_table "showtimes", force: true do |t|
    t.string   "fandango_url"
    t.string   "time"
    t.integer  "theater_id"
    t.integer  "movie_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "three_d"
  end

  add_index "showtimes", ["movie_id"], name: "index_showtimes_on_movie_id"
  add_index "showtimes", ["theater_id"], name: "index_showtimes_on_theater_id"

  create_table "theaters", force: true do |t|
    t.string   "name"
    t.string   "location"
    t.float    "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "normalized_name"
    t.float    "lat"
    t.float    "lng"
    t.text     "photo_reference"
    t.string   "place_id"
  end

end
