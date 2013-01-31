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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130131125336) do

  create_table "animes", :force => true do |t|
    t.string   "age_rating"
    t.integer  "episode_count"
    t.integer  "episode_length"
    t.string   "status"
    t.text     "synopsis"
    t.integer  "mal_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "title"
    t.string   "slug"
    t.string   "youtube_video_id"
  end

  add_index "animes", ["slug"], :name => "index_animes_on_slug", :unique => true

  create_table "animes_genres", :id => false, :force => true do |t|
    t.integer "anime_id", :null => false
    t.integer "genre_id", :null => false
  end

  create_table "animes_producers", :id => false, :force => true do |t|
    t.integer "anime_id",    :null => false
    t.integer "producer_id", :null => false
  end

  create_table "castings", :force => true do |t|
    t.integer  "anime_id"
    t.integer  "character_id"
    t.integer  "voice_actor_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "characters", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "genres", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "slug"
  end

  create_table "people", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "producers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "slug"
  end

  create_table "quotes", :force => true do |t|
    t.text     "content"
    t.integer  "character_id"
    t.integer  "anime_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

end
