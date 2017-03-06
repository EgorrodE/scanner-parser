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

ActiveRecord::Schema.define(version: 20170306133125) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "arp_records", force: :cascade do |t|
    t.string   "ip_address"
    t.string   "hw_type"
    t.string   "hw_address"
    t.string   "flags"
    t.string   "mask"
    t.string   "iface"
    t.datetime "timestamp"
    t.integer  "host_id"
    t.index ["host_id"], name: "index_arp_records_on_host_id", using: :btree
    t.index ["timestamp", "ip_address"], name: "index_arp_records_on_timestamp_and_ip_address", unique: true, using: :btree
  end

  create_table "hosts", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_hosts_on_address", unique: true, using: :btree
  end

  create_table "nmap_records", force: :cascade do |t|
    t.string   "ip_address"
    t.string   "host_name"
    t.string   "status"
    t.datetime "timestamp"
    t.integer  "host_id"
    t.index ["host_id"], name: "index_nmap_records_on_host_id", using: :btree
    t.index ["timestamp", "ip_address"], name: "index_nmap_records_on_timestamp_and_ip_address", unique: true, using: :btree
  end

end
