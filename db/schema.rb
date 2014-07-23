# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090330150138) do

  create_table "activities", :force => true do |t|
    t.boolean  "public"
    t.integer  "item_id"
    t.integer  "user_id"
    t.string   "item_type"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["item_id"], :name => "index_activities_on_item_id"
  add_index "activities", ["item_type"], :name => "index_activities_on_item_type"

  create_table "betakeys", :force => true do |t|
    t.string   "key",                       :null => false
    t.integer  "uses",       :default => 1, :null => false
    t.string   "notes"
    t.integer  "total",      :default => 0
    t.integer  "views",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "betakeys", ["key"], :name => "index_betakeys_on_key", :unique => true

  create_table "comments", :force => true do |t|
    t.integer  "user_id",                   :null => false
    t.integer  "look_id",                   :null => false
    t.string   "body",                      :null => false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "helpful",    :default => 0
    t.integer  "snark",      :default => 0
    t.integer  "vote"
  end

  add_index "comments", ["look_id"], :name => "index_comments_on_look_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "connections", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.integer  "contact_id",                 :null => false
    t.integer  "status",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "accepted_at"
  end

  add_index "connections", ["user_id", "contact_id"], :name => "index_connections_on_user_id_and_contact_id"

  create_table "conversations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favorites", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "item_id",    :null => false
    t.string   "item_type",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["item_id"], :name => "index_favorites_on_item_id"
  add_index "favorites", ["user_id"], :name => "index_favorites_on_user_id"

  create_table "feeds", :force => true do |t|
    t.integer "user_id"
    t.integer "activity_id"
  end

  add_index "feeds", ["user_id", "activity_id"], :name => "index_feeds_on_user_id_and_activity_id"

  create_table "flags", :force => true do |t|
    t.integer  "user_id"
    t.string   "type"
    t.integer  "item_id"
    t.boolean  "resolved"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flags", ["item_id"], :name => "index_flags_on_item_id"
  add_index "flags", ["resolved"], :name => "index_flags_on_resolved"
  add_index "flags", ["type"], :name => "index_flags_on_type"

  create_table "galleries", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "private",         :default => false
    t.string   "title"
    t.string   "description"
    t.integer  "size",            :default => 0,     :null => false
    t.integer  "default_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "galleries", ["user_id"], :name => "index_galleries_on_user_id"

  create_table "gallery_items", :force => true do |t|
    t.integer  "look_id",                         :null => false
    t.integer  "gallery_id",                      :null => false
    t.integer  "default_photo_id"
    t.integer  "user_id"
    t.integer  "description"
    t.integer  "position"
    t.integer  "stashed",          :default => 0
    t.integer  "passed",           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gallery_items", ["gallery_id"], :name => "index_gallery_items_on_gallery_id"
  add_index "gallery_items", ["look_id"], :name => "index_gallery_items_on_look_id"

  create_table "gallery_stats", :force => true do |t|
    t.integer  "user_id",                        :null => false
    t.integer  "gallery_id",                     :null => false
    t.integer  "primary_item_id",                :null => false
    t.integer  "compare_item_id",                :null => false
    t.integer  "primary_passes",  :default => 0
    t.integer  "compare_passes",  :default => 0
    t.integer  "count",           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gallery_stats", ["primary_item_id", "compare_item_id"], :name => "index_gallery_stats_on_primary_item_id_and_compare_item_id"

  create_table "looks", :force => true do |t|
    t.integer  "user_id"
    t.string   "location"
    t.integer  "zip"
    t.string   "store"
    t.string   "title",            :default => "Untitled Look", :null => false
    t.string   "sender"
    t.float    "score",            :default => 0.0,             :null => false
    t.integer  "default_photo_id"
    t.integer  "vote_count",       :default => 0,               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "cached_tag_list"
    t.string   "flavor"
    t.string   "description"
    t.integer  "comment_count",    :default => 0
  end

  add_index "looks", ["comment_count"], :name => "index_looks_on_comment_count"
  add_index "looks", ["score"], :name => "index_looks_on_score"
  add_index "looks", ["store"], :name => "index_looks_on_store"
  add_index "looks", ["vote_count"], :name => "index_looks_on_vote_count"
  add_index "looks", ["zip"], :name => "index_looks_on_zip"

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.integer  "parent_id"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.datetime "receiver_deleted_at"
    t.datetime "receiver_read_at"
    t.datetime "sender_deleted_at"
    t.datetime "sender_read_at"
    t.datetime "last_reply"
    t.boolean  "unread",              :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conversation_id"
  end

  add_index "messages", ["conversation_id"], :name => "index_messages_on_conversation_id"
  add_index "messages", ["receiver_id"], :name => "index_messages_on_receiver_id"
  add_index "messages", ["sender_id"], :name => "index_messages_on_sender_id"

  create_table "photos", :force => true do |t|
    t.integer  "look_id"
    t.integer  "parent_id"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photos", ["look_id"], :name => "index_photos_on_look_id"
  add_index "photos", ["parent_id"], :name => "index_photos_on_parent_id"

  create_table "profile_photos", :force => true do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profile_photos", ["parent_id"], :name => "index_profile_photos_on_parent_id"
  add_index "profile_photos", ["user_id"], :name => "index_profile_photos_on_user_id"

  create_table "profiles", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "login"
    t.string   "name"
    t.string   "phrase"
    t.text     "bio"
    t.string   "avatar"
    t.integer  "size"
    t.integer  "zip"
    t.integer  "age"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["age"], :name => "index_profiles_on_age"
  add_index "profiles", ["updated_at"], :name => "index_profiles_on_updated_at"
  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"
  add_index "profiles", ["zip"], :name => "index_profiles_on_zip"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                                                     :null => false
    t.string   "email",                                                     :null => false
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.integer  "phone"
    t.datetime "birthday"
    t.integer  "zip"
    t.string   "location"
    t.integer  "profile_id"
    t.integer  "age"
    t.string   "beta_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vote_notification",                       :default => 25
    t.boolean  "comment_notification",                    :default => true
    t.integer  "helpful",                                 :default => 0
    t.integer  "snark",                                   :default => 0
    t.string   "recently_viewed"
    t.integer  "unread_count",                            :default => 0,    :null => false
    t.integer  "profile_photo_id"
    t.boolean  "message_notification",                    :default => true, :null => false
  end

  add_index "users", ["age"], :name => "index_users_on_age"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["profile_id"], :name => "index_users_on_profile_id"
  add_index "users", ["updated_at"], :name => "index_users_on_updated_at"
  add_index "users", ["zip"], :name => "index_users_on_zip"

  create_table "votes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "look_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["look_id"], :name => "index_votes_on_look_id"
  add_index "votes", ["score"], :name => "index_votes_on_score"
  add_index "votes", ["user_id"], :name => "index_votes_on_user_id"

end
