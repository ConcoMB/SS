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

ActiveRecord::Schema.define(version: 20131024031812) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "packets", force: true do |t|
    t.integer  "number"
    t.integer  "size"
    t.integer  "arrival"
    t.integer  "simulation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "segments", force: true do |t|
    t.integer  "losts"
    t.integer  "number"
    t.integer  "transmitted"
    t.boolean  "sent",        default: false
    t.integer  "sent_time"
    t.boolean  "ack",         default: false
    t.integer  "packet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "simulations", force: true do |t|
    t.string   "name"
    t.string   "method"
    t.float    "loss_probability"
    t.float    "lambda"
    t.float    "length_avg"
    t.float    "length_dev"
    t.integer  "total_packets"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "time_mean"
    t.float    "ratio_mean"
  end

end
