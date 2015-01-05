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

ActiveRecord::Schema.define(version: 20141113014149) do

  create_table "book_records", force: true do |t|
    t.integer  "shop_id"
    t.integer  "time_9"
    t.integer  "time_10"
    t.integer  "time_11"
    t.integer  "time_12"
    t.integer  "time_13"
    t.integer  "time_14"
    t.integer  "time_15"
    t.integer  "time_16"
    t.integer  "time_17"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brands", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "brand_photo"
  end

  create_table "comment_notifications", force: true do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.integer  "status"
    t.integer  "comment_notification_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.string   "content"
    t.integer  "status"
    t.integer  "bonus_integral"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discount_discount_types", force: true do |t|
    t.integer  "discount_id"
    t.integer  "discount_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "discount_types", force: true do |t|
    t.string   "name"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent"
    t.integer  "icon"
  end

  create_table "discounts", force: true do |t|
    t.integer  "shop_id"
    t.string   "title"
    t.text     "content"
    t.decimal  "price",                    precision: 10, scale: 0
    t.float    "discount",      limit: 24
    t.boolean  "hot"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "integral",      limit: 24
    t.integer  "visitor_count"
    t.decimal  "sale_price",               precision: 10, scale: 0
  end

  create_table "documents", force: true do |t|
    t.integer  "shop_id"
    t.integer  "discount_id"
    t.integer  "document_type"
    t.integer  "status"
    t.string   "screenshot"
    t.string   "original"
    t.string   "title"
    t.string   "file_name"
    t.integer  "upload_file_size"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employee_roles", force: true do |t|
    t.integer  "role_id"
    t.integer  "employee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "employees", force: true do |t|
    t.integer  "shop_id"
    t.string   "name"
    t.string   "phone"
    t.integer  "authority"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "auth_token"
    t.string   "password_digest"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

  create_table "log_records", force: true do |t|
    t.string   "title"
    t.string   "content"
    t.string   "log_record_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_notifications", force: true do |t|
    t.integer  "user_id"
    t.integer  "order_id"
    t.integer  "status"
    t.integer  "order_notification_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: true do |t|
    t.integer  "discount_id"
    t.integer  "user_id"
    t.string   "order_number"
    t.integer  "status"
    t.decimal  "price",                    precision: 10, scale: 0
    t.string   "remark"
    t.string   "alipay_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "integral",      limit: 24
    t.boolean  "is_car_wash"
    t.datetime "book_time"
  end

  create_table "pre_schedule_records", force: true do |t|
    t.integer  "shop_id"
    t.integer  "time_9"
    t.integer  "time_10"
    t.integer  "time_11"
    t.integer  "time_12"
    t.integer  "time_13"
    t.integer  "time_14"
    t.integer  "time_15"
    t.integer  "time_16"
    t.integer  "time_17"
    t.datetime "start_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "authority"
    t.string   "duty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schedule_records", force: true do |t|
    t.integer  "shop_id"
    t.integer  "time_9"
    t.integer  "time_10"
    t.integer  "time_11"
    t.integer  "time_12"
    t.integer  "time_13"
    t.integer  "time_14"
    t.integer  "time_15"
    t.integer  "time_16"
    t.integer  "time_17"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "score_notifications", force: true do |t|
    t.integer  "user_id"
    t.integer  "score_record_id"
    t.integer  "status"
    t.integer  "score_notification_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "score_records", force: true do |t|
    t.integer  "order_id"
    t.integer  "user_id"
    t.float    "wash_grade",    limit: 24
    t.float    "service_grade", limit: 24
    t.float    "speed_grade",   limit: 24
    t.float    "env_grade",     limit: 24
    t.float    "average_grade", limit: 24
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shops", force: true do |t|
    t.integer  "brand_id"
    t.string   "name"
    t.string   "address"
    t.float    "longitude",                   limit: 24
    t.float    "latitude",                    limit: 24
    t.string   "telephone_number"
    t.string   "telephone_area_code"
    t.integer  "shop_photo"
    t.text     "description"
    t.boolean  "car_wash_bookable"
    t.boolean  "car_wash_online_pay_support"
    t.float    "extra_priority",              limit: 24
    t.datetime "extra_priority_end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "cooperation"
    t.datetime "extra_priority_start_time"
  end

  create_table "user_brands", force: true do |t|
    t.integer  "brand_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_discount_praises", force: true do |t|
    t.integer  "discount_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_discounts", force: true do |t|
    t.integer  "discount_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_shops", force: true do |t|
    t.integer  "shop_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "account"
    t.string   "phone"
    t.string   "licence_plate"
    t.string   "email"
    t.integer  "integral"
    t.decimal  "balance",                           precision: 10, scale: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "car_type"
    t.float    "percent",                limit: 24
    t.integer  "user_photo"
    t.integer  "car_photo"
    t.string   "auth_token"
    t.string   "password_digest"
    t.integer  "sex"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

end
