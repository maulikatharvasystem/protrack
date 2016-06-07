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

ActiveRecord::Schema.define(:version => 20150311094247) do

  create_table "admins", :primary_key => "pk_admin_id", :force => true do |t|
    t.integer  "fk_user_type_id",  :limit => 8,   :default => 0,                     :null => false
    t.string   "salt",             :limit => 100, :default => "",                    :null => false
    t.string   "encrypt_pwd",      :limit => 100, :default => "",                    :null => false
    t.string   "reset_pswd_token", :limit => 50,  :default => "",                    :null => false
    t.datetime "reset_pswd_at",                   :default => '1900-01-01 00:00:00', :null => false
    t.string   "admin_name",       :limit => 50,  :default => "",                    :null => false
    t.string   "contact_person",   :limit => 50,  :default => "",                    :null => false
    t.string   "phone",            :limit => 25,  :default => "",                    :null => false
    t.string   "address",          :limit => 250, :default => "",                    :null => false
    t.string   "email",            :limit => 50,  :default => "",                    :null => false
    t.string   "website",          :limit => 100, :default => "",                    :null => false
    t.datetime "create_at",                       :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",        :limit => 40,  :default => "",                    :null => false
    t.datetime "last_updated_at",                 :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip",  :limit => 40,  :default => "",                    :null => false
    t.integer  "status_code",                     :default => 0,                     :null => false
    t.integer  "sign_in_count",    :limit => 8,   :default => 0,                     :null => false
  end

  add_index "admins", ["fk_user_type_id"], :name => "fk_user_type_id"

  create_table "apn_apps", :force => true do |t|
    t.text     "apn_dev_cert"
    t.text     "apn_prod_cert"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "apn_device_groupings", :force => true do |t|
    t.integer "group_id"
    t.integer "device_id"
  end

  add_index "apn_device_groupings", ["device_id"], :name => "index_apn_device_groupings_on_device_id"
  add_index "apn_device_groupings", ["group_id", "device_id"], :name => "index_apn_device_groupings_on_group_id_and_device_id"
  add_index "apn_device_groupings", ["group_id"], :name => "index_apn_device_groupings_on_group_id"

  create_table "apn_devices", :force => true do |t|
    t.string   "token",              :default => "", :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.datetime "last_registered_at"
    t.integer  "app_id"
  end

  add_index "apn_devices", ["token"], :name => "index_apn_devices_on_token"

  create_table "apn_group_notifications", :force => true do |t|
    t.integer  "group_id",          :null => false
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.text     "custom_properties"
    t.datetime "sent_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "apn_group_notifications", ["group_id"], :name => "index_apn_group_notifications_on_group_id"

  create_table "apn_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "app_id"
  end

  create_table "apn_notifications", :force => true do |t|
    t.integer  "device_id",                        :null => false
    t.integer  "errors_nb",         :default => 0
    t.string   "device_language"
    t.string   "sound"
    t.string   "alert"
    t.integer  "badge"
    t.datetime "sent_at"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.text     "custom_properties"
  end

  add_index "apn_notifications", ["device_id"], :name => "index_apn_notifications_on_device_id"

  create_table "apn_pull_notifications", :force => true do |t|
    t.integer  "app_id"
    t.string   "title"
    t.string   "content"
    t.string   "link"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.boolean  "launch_notification"
  end

  create_table "client_track_images", :primary_key => "pk_image_id", :force => true do |t|
    t.string  "track_image", :limit => 1000, :default => "", :null => false
    t.integer "fk_track_id", :limit => 8,    :default => 0,  :null => false
    t.integer "status_code",                 :default => 0,  :null => false
    t.integer "image_code",                  :default => 0,  :null => false
  end

  add_index "client_track_images", ["fk_track_id"], :name => "fk_track_id"

  create_table "client_tracks", :primary_key => "pk_track_id", :force => true do |t|
    t.integer  "fk_client_id",           :limit => 8,    :default => 0,                     :null => false
    t.string   "display_id",             :limit => 10,   :default => "",                    :null => false
    t.string   "track_name",             :limit => 50,   :default => "",                    :null => false
    t.string   "track_tip",              :limit => 500,  :default => "",                    :null => false
    t.text     "description",                                                               :null => false
    t.string   "track_image",            :limit => 1000, :default => "",                    :null => false
    t.string   "small_track_image",      :limit => 1000, :default => "",                    :null => false
    t.string   "med_track_image",        :limit => 1000, :default => "",                    :null => false
    t.string   "track_info_image",       :limit => 1000, :default => "",                    :null => false
    t.string   "small_track_info_image", :limit => 1000, :default => "",                    :null => false
    t.string   "med_track_info_image",   :limit => 1000, :default => "",                    :null => false
    t.integer  "fk_product_id",          :limit => 8,    :default => 0,                     :null => false
    t.integer  "no_turns",                               :default => 0,                     :null => false
    t.integer  "platform_code",                          :default => 0,                     :null => false
    t.datetime "create_at",                              :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",              :limit => 40,   :default => "",                    :null => false
    t.datetime "last_updated_at",                        :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip",        :limit => 40,   :default => "",                    :null => false
    t.integer  "status_code",                            :default => 0,                     :null => false
    t.string   "note"
    t.string   "timing_url"
    t.string   "media_url"
    t.string   "weather_url"
    t.string   "lap_video_url"
    t.string   "schedule_pdf_url"
    t.integer  "series_id"
  end

  add_index "client_tracks", ["fk_client_id"], :name => "fk_client_id"
  add_index "client_tracks", ["fk_product_id"], :name => "fk_product_id"

  create_table "client_users", :primary_key => "pk_clientuser_id", :force => true do |t|
    t.integer  "fk_client_id",     :limit => 8,   :default => 0,                     :null => false
    t.integer  "fk_urole_id",      :limit => 8,   :default => 0,                     :null => false
    t.string   "salt",             :limit => 100, :default => "",                    :null => false
    t.string   "encrypt_pwd",      :limit => 100, :default => "",                    :null => false
    t.string   "reset_pswd_token", :limit => 50,  :default => "",                    :null => false
    t.datetime "reset_pswd_at",                   :default => '1900-01-01 00:00:00', :null => false
    t.string   "client_user_name", :limit => 50,  :default => "",                    :null => false
    t.string   "company_name",     :limit => 50,  :default => "",                    :null => false
    t.string   "phone",            :limit => 25,  :default => "",                    :null => false
    t.string   "address",          :limit => 250, :default => "",                    :null => false
    t.string   "email",            :limit => 50,  :default => "",                    :null => false
    t.string   "website",          :limit => 100, :default => "",                    :null => false
    t.datetime "create_at",                       :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",        :limit => 40,  :default => "",                    :null => false
    t.datetime "last_updated_at",                 :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip",  :limit => 40,  :default => "",                    :null => false
    t.integer  "status_code",                     :default => 0,                     :null => false
  end

  add_index "client_users", ["fk_client_id"], :name => "fk_client_id"
  add_index "client_users", ["fk_urole_id"], :name => "fk_urole_id"

  create_table "client_users_track_rights", :primary_key => "pk_rights_id", :force => true do |t|
    t.integer  "fk_clientuser_id", :limit => 8,  :default => 0,                     :null => false
    t.integer  "fk_client_id",     :limit => 8,  :default => 0,                     :null => false
    t.integer  "fk_track_id",      :limit => 8,  :default => 0,                     :null => false
    t.datetime "create_at",                      :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",        :limit => 40, :default => "",                    :null => false
    t.datetime "last_updated_at",                :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip",  :limit => 40, :default => "",                    :null => false
    t.integer  "status_code",                    :default => 0,                     :null => false
  end

  add_index "client_users_track_rights", ["fk_client_id"], :name => "fk_client_id"
  add_index "client_users_track_rights", ["fk_clientuser_id"], :name => "fk_clientuser_id"
  add_index "client_users_track_rights", ["fk_track_id"], :name => "fk_track_id"

  create_table "clients", :primary_key => "pk_client_id", :force => true do |t|
    t.integer  "fk_user_type_id",  :limit => 8,   :default => 0,                     :null => false
    t.string   "salt",             :limit => 100, :default => "",                    :null => false
    t.string   "encrypt_pwd",      :limit => 100, :default => "",                    :null => false
    t.string   "reset_pswd_token", :limit => 50,  :default => "",                    :null => false
    t.datetime "reset_pswd_at",                   :default => '1900-01-01 00:00:00', :null => false
    t.string   "client_name",      :limit => 50,  :default => "",                    :null => false
    t.string   "contact_person",   :limit => 50,  :default => "",                    :null => false
    t.string   "phone",            :limit => 25,  :default => "",                    :null => false
    t.string   "address",          :limit => 250, :default => "",                    :null => false
    t.string   "email",            :limit => 50,  :default => "",                    :null => false
    t.string   "website",          :limit => 100, :default => "",                    :null => false
    t.datetime "create_at",                       :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",        :limit => 40,  :default => "",                    :null => false
    t.datetime "last_updated_at",                 :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip",  :limit => 40,  :default => "",                    :null => false
    t.integer  "status_code",                     :default => 0,                     :null => false
    t.integer  "sign_in_count",    :limit => 8,   :default => 0,                     :null => false
  end

  add_index "clients", ["fk_user_type_id"], :name => "fk_user_type_id"

  create_table "device_users", :primary_key => "pk_user_id", :force => true do |t|
    t.integer  "fk_client_id",      :limit => 8,   :default => 0,                     :null => false
    t.string   "email",             :limit => 50,  :default => "",                    :null => false
    t.string   "password",          :limit => 32,  :default => "",                    :null => false
    t.string   "first_name",        :limit => 25,  :default => "",                    :null => false
    t.string   "last_name",         :limit => 25,  :default => "",                    :null => false
    t.string   "phone",             :limit => 25,  :default => "",                    :null => false
    t.string   "address",           :limit => 250, :default => "",                    :null => false
    t.date     "dob",                              :default => '1900-01-01',          :null => false
    t.integer  "last_fk_device_id", :limit => 8,   :default => 0
    t.datetime "create_at",                        :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",         :limit => 40,  :default => "",                    :null => false
    t.datetime "last_updated_at",                  :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip",   :limit => 40,  :default => "",                    :null => false
    t.integer  "status_code",                      :default => 0,                     :null => false
    t.integer  "last_timestamp",    :limit => 8,   :default => 0,                     :null => false
    t.integer  "sessionid",         :limit => 8,   :default => 0,                     :null => false
    t.string   "file_name",         :limit => 250, :default => "",                    :null => false
  end

  add_index "device_users", ["fk_client_id"], :name => "fk_client_id"

  create_table "image_code_master", :primary_key => "pk_image_code_id", :force => true do |t|
    t.integer "code",        :default => 0,  :null => false
    t.string  "name",        :default => "", :null => false
    t.text    "description",                 :null => false
  end

  create_table "managa_urls", :force => true do |t|
    t.integer  "admin_id"
    t.string   "regulation_pdf"
    t.string   "media_pdf"
    t.string   "car_manual_pdf"
    t.string   "fb_url"
    t.string   "twitter_url"
    t.string   "prema_url"
    t.string   "formula_url"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "manage_urls", :force => true do |t|
    t.integer  "admin_id"
    t.string   "regulation_pdf"
    t.string   "media_pdf"
    t.string   "car_manual_pdf"
    t.string   "fb_url"
    t.string   "twitter_url"
    t.string   "prema_url"
    t.string   "formula_url"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "product_prices", :primary_key => "pk_product_id", :force => true do |t|
    t.integer  "fk_client_id",       :limit => 8,                                 :default => 0,                     :null => false
    t.string   "ios_product_id",                                                  :default => "",                    :null => false
    t.string   "android_product_id", :limit => 25,                                :default => "",                    :null => false
    t.string   "description",        :limit => 500,                               :default => "",                    :null => false
    t.decimal  "ios_price",                         :precision => 6, :scale => 2, :default => 0.0,                   :null => false
    t.decimal  "android_price",                     :precision => 6, :scale => 2, :default => 0.0,                   :null => false
    t.datetime "create_at",                                                       :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",          :limit => 40,                                :default => "",                    :null => false
    t.datetime "last_updated_at",                                                 :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip",    :limit => 40,                                :default => "",                    :null => false
    t.integer  "status_code",                                                     :default => 0,                     :null => false
  end

  add_index "product_prices", ["fk_client_id"], :name => "fk_client_id"

  create_table "race_engineer_reports", :force => true do |t|
    t.integer  "client_id",        :limit => 8
    t.integer  "race_engineer_id", :limit => 8
    t.string   "name"
    t.date     "report_date"
    t.integer  "driver_id",        :limit => 8
    t.string   "engineer_name"
    t.string   "championship"
    t.string   "circuit"
    t.string   "event"
    t.text     "report_info"
    t.string   "create_ip"
    t.string   "last_updated_ip"
    t.integer  "status_code"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "race_engineers", :primary_key => "pk_engn_id", :force => true do |t|
    t.integer  "fk_client_id",       :limit => 8,                                      :null => false
    t.integer  "fk_user_type_id",    :limit => 8,   :default => 0,                     :null => false
    t.string   "salt",               :limit => 100, :default => "",                    :null => false
    t.string   "encrypt_pwd",        :limit => 100, :default => "",                    :null => false
    t.string   "reset_pswd_token",   :limit => 50,  :default => "",                    :null => false
    t.datetime "reset_pswd_at",                     :default => '1900-01-01 00:00:00', :null => false
    t.string   "race_engineer_name", :limit => 50,  :default => "",                    :null => false
    t.string   "contact_person",     :limit => 50,  :default => "",                    :null => false
    t.string   "phone",              :limit => 25,  :default => "",                    :null => false
    t.string   "address",            :limit => 250, :default => "",                    :null => false
    t.string   "email",              :limit => 50,  :default => "",                    :null => false
    t.string   "website",            :limit => 100, :default => "",                    :null => false
    t.datetime "create_at",                         :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",          :limit => 40,  :default => "",                    :null => false
    t.datetime "last_updated_at",                   :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip",    :limit => 40,  :default => "",                    :null => false
    t.integer  "status_code",                       :default => 0,                     :null => false
    t.integer  "sign_in_count",      :limit => 8,   :default => 0,                     :null => false
  end

  add_index "race_engineers", ["fk_client_id"], :name => "fk_client_id"
  add_index "race_engineers", ["fk_user_type_id"], :name => "fk_user_type_id"

  create_table "role_details", :primary_key => "pk_role_id", :force => true do |t|
    t.integer  "fk_urole_id",     :limit => 8,   :default => 0,                     :null => false
    t.string   "role_name",       :limit => 50,  :default => "",                    :null => false
    t.string   "description",     :limit => 500, :default => "",                    :null => false
    t.string   "controller_name", :limit => 50,  :default => "",                    :null => false
    t.string   "action_name",     :limit => 50,  :default => "",                    :null => false
    t.datetime "create_at",                      :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",       :limit => 40,  :default => "",                    :null => false
    t.datetime "last_updated_at",                :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip", :limit => 40,  :default => "",                    :null => false
    t.integer  "status_code",                    :default => 0,                     :null => false
  end

  add_index "role_details", ["fk_urole_id"], :name => "fk_urole_id"
  add_index "role_details", ["pk_role_id"], :name => "pk_role_id"

  create_table "series", :force => true do |t|
    t.string   "series"
    t.string   "regulations_pdf_url"
    t.string   "media_pdf_url"
    t.string   "car_manual_pdf_url"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "track_placement_types", :primary_key => "pk_plactype_id", :force => true do |t|
    t.string   "plac_name",       :limit => 25,  :default => "",                    :null => false
    t.string   "plac_descr",      :limit => 500, :default => "",                    :null => false
    t.datetime "create_at",                      :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",       :limit => 40,  :default => "",                    :null => false
    t.datetime "last_updated_at",                :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip", :limit => 40,  :default => "",                    :null => false
    t.integer  "status_code",                    :default => 0,                     :null => false
  end

  create_table "track_session_images", :primary_key => "pk_image_id", :force => true do |t|
    t.string  "session_image", :limit => 1000, :default => "",  :null => false
    t.integer "fk_session_id", :limit => 8,    :default => 0,   :null => false
    t.integer "status_code",                   :default => 401, :null => false
    t.integer "image_code",                    :default => 0,   :null => false
  end

  add_index "track_session_images", ["fk_session_id"], :name => "fk_session_id"

  create_table "track_session_reports", :force => true do |t|
    t.string   "session_report"
    t.integer  "fk_session_id"
    t.integer  "status_code"
    t.integer  "report_code"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "track_sessions", :primary_key => "pk_session_id", :force => true do |t|
    t.integer  "fk_client_id",    :limit => 8,                                     :null => false
    t.integer  "fk_engn_id",      :limit => 8,                                     :null => false
    t.string   "name",                          :default => "",                    :null => false
    t.date     "session_date",                  :default => '1900-01-01',          :null => false
    t.integer  "fk_driver_id",    :limit => 8,                                     :null => false
    t.string   "engineer_name",                 :default => "",                    :null => false
    t.string   "championship",                  :default => "",                    :null => false
    t.string   "circuit",                       :default => "",                    :null => false
    t.string   "event",                         :default => "",                    :null => false
    t.datetime "create_at",                                                        :null => false
    t.string   "create_ip",       :limit => 40, :default => "1900-01-01 00:00:00", :null => false
    t.datetime "last_updated_at",               :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip", :limit => 40, :default => "",                    :null => false
    t.integer  "status_code",                   :default => 401,                   :null => false
  end

  add_index "track_sessions", ["fk_driver_id"], :name => "fk_driver_id"

  create_table "track_turn_images", :primary_key => "pk_image_id", :force => true do |t|
    t.string  "turn_image",  :limit => 1000, :default => "", :null => false
    t.integer "fk_tn_id",    :limit => 8,    :default => 0,  :null => false
    t.integer "status_code",                 :default => 0,  :null => false
    t.integer "image_code",                  :default => 0,  :null => false
  end

  add_index "track_turn_images", ["fk_tn_id"], :name => "fk_tn_id"

  create_table "track_turn_notes", :primary_key => "pk_tn_id", :force => true do |t|
    t.integer  "fk_track_id",     :limit => 8,          :default => 0,                     :null => false
    t.integer  "fk_client_id",    :limit => 8,          :default => 0,                     :null => false
    t.integer  "fk_plactype_id",  :limit => 8,          :default => 0,                     :null => false
    t.integer  "tn_step_id",                            :default => 0,                     :null => false
    t.string   "tn_name",         :limit => 25,         :default => "",                    :null => false
    t.text     "tn_data",         :limit => 2147483647,                                    :null => false
    t.string   "tn_video",        :limit => 1000,       :default => "",                    :null => false
    t.string   "tn_type",         :limit => 500,        :default => "",                    :null => false
    t.string   "tn_strategy",     :limit => 500,        :default => "",                    :null => false
    t.string   "tn_marker",       :limit => 500,        :default => "",                    :null => false
    t.string   "tn_picture",      :limit => 1000,       :default => "",                    :null => false
    t.string   "tn_note",         :limit => 500,        :default => "",                    :null => false
    t.integer  "x_pos",           :limit => 8,          :default => 0,                     :null => false
    t.integer  "y_pos",           :limit => 8,          :default => 0,                     :null => false
    t.integer  "sort_no",                               :default => 0,                     :null => false
    t.datetime "create_at",                             :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",       :limit => 40,         :default => "",                    :null => false
    t.datetime "last_updated_at",                       :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip", :limit => 40,         :default => "",                    :null => false
    t.integer  "status_code",                           :default => 0,                     :null => false
  end

  add_index "track_turn_notes", ["fk_client_id"], :name => "fk_client_id"
  add_index "track_turn_notes", ["fk_plactype_id"], :name => "fk_plactype_id"
  add_index "track_turn_notes", ["fk_track_id"], :name => "fk_track_id"

  create_table "transactions", :primary_key => "pk_trans_id", :force => true do |t|
    t.integer  "fk_client_id",            :limit => 8,                                         :default => 0,                     :null => false
    t.integer  "fk_track_id",             :limit => 8,                                         :default => 0,                     :null => false
    t.integer  "platform_code",                                                                :default => 0,                     :null => false
    t.integer  "fk_device_id",            :limit => 8,                                                                            :null => false
    t.string   "product_id",              :limit => 100,                                       :default => "",                    :null => false
    t.datetime "start_date",                                                                   :default => '1900-01-01 00:00:00', :null => false
    t.datetime "end_date",                                                                     :default => '1900-01-01 00:00:00', :null => false
    t.text     "latest_receipt",          :limit => 2147483647,                                                                   :null => false
    t.string   "bid",                     :limit => 100,                                       :default => "",                    :null => false
    t.string   "bvrs",                    :limit => 100,                                       :default => "",                    :null => false
    t.integer  "expires_date",            :limit => 8,                                         :default => 0,                     :null => false
    t.string   "item_id",                 :limit => 100,                                       :default => "",                    :null => false
    t.string   "original_purchase_date",  :limit => 100,                                       :default => "",                    :null => false
    t.string   "original_transaction_id", :limit => 100,                                       :default => "",                    :null => false
    t.string   "purchase_date",           :limit => 100,                                       :default => "",                    :null => false
    t.integer  "quantity",                                                                     :default => 0,                     :null => false
    t.string   "transaction_id",          :limit => 100,                                       :default => "",                    :null => false
    t.string   "order_id",                :limit => 100,                                       :default => "",                    :null => false
    t.string   "gateway",                 :limit => 20,                                        :default => "",                    :null => false
    t.integer  "purchase_state",                                                               :default => 0,                     :null => false
    t.decimal  "price",                                         :precision => 18, :scale => 2, :default => 0.0,                   :null => false
    t.datetime "create_at",                                                                    :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",               :limit => 40,                                        :default => "",                    :null => false
    t.integer  "status_code",                                                                  :default => 0,                     :null => false
  end

  add_index "transactions", ["fk_client_id"], :name => "fk_client_id"
  add_index "transactions", ["fk_track_id"], :name => "fk_track_id"

  create_table "user_devices", :primary_key => "pk_device_id", :force => true do |t|
    t.integer  "fk_client_id",    :limit => 8,          :default => 0,                     :null => false
    t.integer  "platform_code",                         :default => 0,                     :null => false
    t.string   "app_name",                              :default => "",                    :null => false
    t.string   "app_version",     :limit => 25,         :default => "",                    :null => false
    t.text     "device_token",    :limit => 2147483647,                                    :null => false
    t.string   "device_id",                             :default => "",                    :null => false
    t.string   "device_name",                           :default => "",                    :null => false
    t.string   "device_model",    :limit => 100,        :default => "",                    :null => false
    t.string   "device_version",  :limit => 25,         :default => "",                    :null => false
    t.integer  "push_badge",      :limit => 2,          :default => 0,                     :null => false
    t.integer  "push_alert",      :limit => 2,          :default => 0,                     :null => false
    t.string   "push_sound",      :limit => 25,         :default => "",                    :null => false
    t.integer  "devlopment",      :limit => 2,          :default => 0,                     :null => false
    t.string   "lang_code",       :limit => 3,          :default => "",                    :null => false
    t.string   "country_code",    :limit => 4,          :default => "",                    :null => false
    t.string   "os_version",      :limit => 25,         :default => "",                    :null => false
    t.datetime "create_at",                             :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",       :limit => 40,         :default => "",                    :null => false
    t.datetime "last_updated_at",                       :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip", :limit => 40,         :default => "",                    :null => false
    t.integer  "status_code",                           :default => 0,                     :null => false
    t.integer  "last_timestamp",  :limit => 8,          :default => 0,                     :null => false
  end

  add_index "user_devices", ["fk_client_id"], :name => "fk_client_id"

  create_table "user_report_fields", :primary_key => "pk_field_id", :force => true do |t|
    t.integer "fk_report_id", :limit => 8,                    :null => false
    t.integer "fk_client_id", :limit => 8,                    :null => false
    t.integer "fk_user_id",   :limit => 8,                    :null => false
    t.string  "key",                       :default => "",    :null => false
    t.string  "name",                      :default => "",    :null => false
    t.text    "value",                                        :null => false
    t.boolean "need_rating",               :default => false, :null => false
    t.integer "rating",                    :default => 0,     :null => false
  end

  add_index "user_report_fields", ["fk_client_id"], :name => "fk_client_id"
  add_index "user_report_fields", ["fk_report_id"], :name => "fk_report_id"
  add_index "user_report_fields", ["fk_user_id"], :name => "fk_user_id"

  create_table "user_reports", :primary_key => "pk_report_id", :force => true do |t|
    t.integer  "fk_client_id",    :limit => 8,                                     :null => false
    t.integer  "fk_user_id",      :limit => 8,                                     :null => false
    t.string   "name",                          :default => "",                    :null => false
    t.string   "circuit",                       :default => "",                    :null => false
    t.string   "engineer_name",                 :default => "",                    :null => false
    t.string   "event",                         :default => "",                    :null => false
    t.string   "report_time",                   :default => "",                    :null => false
    t.string   "championship",                                                     :null => false
    t.datetime "create_at",                     :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",       :limit => 40, :default => "",                    :null => false
    t.datetime "last_updated_at",               :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip", :limit => 40, :default => "",                    :null => false
    t.integer  "status_code",                   :default => 0,                     :null => false
  end

  add_index "user_reports", ["fk_client_id"], :name => "fk_client_id"
  add_index "user_reports", ["fk_user_id"], :name => "fk_user_id"

  create_table "user_restore_app_infos", :primary_key => "pk_user_restore_id", :force => true do |t|
    t.integer  "fk_client_id",    :limit => 8,          :default => 0,                     :null => false
    t.text     "str_fk_trans_id", :limit => 2147483647,                                    :null => false
    t.text     "str_fk_track_id", :limit => 2147483647,                                    :null => false
    t.integer  "fk_device_id",    :limit => 8,          :default => 0,                     :null => false
    t.text     "device_id",       :limit => 2147483647,                                    :null => false
    t.datetime "create_at",                             :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",       :limit => 40,         :default => "",                    :null => false
  end

  add_index "user_restore_app_infos", ["fk_client_id"], :name => "fk_client_id"
  add_index "user_restore_app_infos", ["fk_device_id"], :name => "fk_device_id"

  create_table "user_roles", :primary_key => "pk_urole_id", :force => true do |t|
    t.string   "user_role_name",  :limit => 50,  :default => "",                    :null => false
    t.string   "description",     :limit => 500, :default => "",                    :null => false
    t.datetime "create_at",                      :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",       :limit => 40,  :default => "",                    :null => false
    t.datetime "last_updated_at",                :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip", :limit => 40,  :default => "",                    :null => false
    t.integer  "status_code",                    :default => 0,                     :null => false
  end

  create_table "user_turn_notes", :primary_key => "pk_utn_id", :force => true do |t|
    t.integer  "fk_user_id",                                                         :null => false
    t.integer  "fk_tn_id",        :limit => 8,    :default => 0,                     :null => false
    t.integer  "fk_client_id",    :limit => 8,    :default => 0,                     :null => false
    t.string   "tn_type",         :limit => 500,  :default => "",                    :null => false
    t.text     "tip",                                                                :null => false
    t.string   "tn_strategy",     :limit => 500,  :default => "",                    :null => false
    t.string   "tn_marker",       :limit => 500,  :default => "",                    :null => false
    t.string   "tn_picture",      :limit => 1000, :default => "",                    :null => false
    t.string   "tn_note",         :limit => 500,  :default => "",                    :null => false
    t.datetime "create_at",                       :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",       :limit => 40,   :default => "",                    :null => false
    t.datetime "last_updated_at",                 :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip", :limit => 40,   :default => "",                    :null => false
    t.integer  "status_code",                     :default => 0,                     :null => false
  end

  add_index "user_turn_notes", ["fk_client_id"], :name => "fk_client_id"
  add_index "user_turn_notes", ["fk_tn_id"], :name => "fk_track_id"

  create_table "user_types", :primary_key => "pk_user_type", :force => true do |t|
    t.string   "user_type",       :limit => 20,  :default => "",                    :null => false
    t.string   "description",     :limit => 500, :default => "",                    :null => false
    t.boolean  "is_admin",                       :default => false,                 :null => false
    t.datetime "create_at",                      :default => '1900-01-01 00:00:00', :null => false
    t.string   "create_ip",       :limit => 40,  :default => "",                    :null => false
    t.datetime "last_updated_at",                :default => '1900-01-01 00:00:00', :null => false
    t.string   "last_updated_ip", :limit => 40,  :default => "",                    :null => false
    t.integer  "status_code",                    :default => 0,                     :null => false
  end

end
