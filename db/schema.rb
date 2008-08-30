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

ActiveRecord::Schema.define(:version => 20080828203501) do

  create_table "connectors", :force => true do |t|
    t.integer  "page_id",            :limit => 11
    t.string   "container"
    t.integer  "content_block_id",   :limit => 11
    t.string   "content_block_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "content_types", :force => true do |t|
    t.string   "name"
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "html_blocks", :force => true do |t|
    t.string   "name"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_templates", :force => true do |t|
    t.string   "name"
    t.string   "file_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.integer  "section_id",  :limit => 11
    t.integer  "template_id", :limit => 11
    t.string   "name"
    t.string   "path"
    t.string   "status",                    :default => "IN_PROGRESS"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portlet_attributes", :force => true do |t|
    t.integer "portlet_id", :limit => 11
    t.string  "name"
    t.string  "value"
  end

  create_table "portlet_types", :force => true do |t|
    t.string   "name"
    t.text     "form"
    t.text     "code"
    t.text     "template"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portlets", :force => true do |t|
    t.string   "portlet_type_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "registered_blocks", :force => true do |t|
    t.string "name"
  end

  create_table "sections", :force => true do |t|
    t.integer  "parent_id",  :limit => 11
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "first_name",                :limit => 40
    t.string   "last_name",                 :limit => 40
    t.string   "email",                     :limit => 40
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
