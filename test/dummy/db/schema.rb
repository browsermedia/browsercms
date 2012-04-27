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

ActiveRecord::Schema.define(:version => 20120427193220) do

  create_table "catalog_versions", :force => true do |t|
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "name"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "catalogs", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",  :default => 0
    t.string   "name"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "published",     :default => false
    t.boolean  "deleted",       :default => false
    t.boolean  "archived",      :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "categories", :force => true do |t|
    t.integer  "category_type_id"
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "category_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cms_attachment_versions", :force => true do |t|
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "data_file_path"
    t.string   "file_location"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data_file_name"
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "data_fingerprint"
    t.string   "attachable_type"
    t.string   "attachment_name"
    t.integer  "attachable_id"
    t.integer  "attachable_version"
    t.string   "cardinality"
  end

  add_index "cms_attachment_versions", ["original_record_id"], :name => "index_attachment_versions_on_attachment_id"

  create_table "cms_attachments", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",       :default => 0
    t.string   "data_file_path"
    t.string   "file_location"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data_file_name"
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "data_fingerprint"
    t.string   "attachable_type"
    t.string   "attachment_name"
    t.integer  "attachable_id"
    t.integer  "attachable_version"
    t.string   "cardinality"
  end

  create_table "connectors", :force => true do |t|
    t.integer  "page_id"
    t.integer  "page_version"
    t.integer  "connectable_id"
    t.string   "connectable_type"
    t.integer  "connectable_version"
    t.string   "container"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connectors", ["connectable_type"], :name => "index_connectors_on_connectable_type"
  add_index "connectors", ["connectable_version"], :name => "index_connectors_on_connectable_version"
  add_index "connectors", ["page_id"], :name => "index_connectors_on_page_id"
  add_index "connectors", ["page_version"], :name => "index_connectors_on_page_version"

  create_table "content_type_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "content_types", :force => true do |t|
    t.string   "name"
    t.integer  "content_type_group_id"
    t.integer  "priority",              :default => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_types", ["content_type_group_id"], :name => "index_content_types_on_content_type_group_id"
  add_index "content_types", ["name"], :name => "index_content_types_on_name"

  create_table "dynamic_view_versions", :force => true do |t|
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "type"
    t.string   "name"
    t.string   "format"
    t.string   "handler"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "dynamic_views", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",  :default => 0
    t.string   "type"
    t.string   "name"
    t.string   "format"
    t.string   "handler"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",     :default => false
    t.boolean  "deleted",       :default => false
    t.boolean  "archived",      :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "email_messages", :force => true do |t|
    t.string   "sender"
    t.text     "recipients"
    t.text     "subject"
    t.text     "cc"
    t.text     "bcc"
    t.text     "body"
    t.string   "content_type"
    t.datetime "delivered_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_versions", :force => true do |t|
    t.integer  "event_id"
    t.integer  "version"
    t.string   "name"
    t.string   "slug"
    t.date     "starts_on"
    t.date     "ends_on"
    t.string   "location"
    t.string   "contact_email"
    t.text     "description"
    t.string   "more_info_url"
    t.string   "registration_url"
    t.integer  "category_id"
    t.text     "body"
    t.boolean  "published",        :default => false
    t.boolean  "deleted",          :default => false
    t.boolean  "archived",         :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",     :default => 0
    t.string   "name"
    t.string   "slug"
    t.date     "starts_on"
    t.date     "ends_on"
    t.string   "location"
    t.string   "contact_email"
    t.text     "description"
    t.string   "more_info_url"
    t.string   "registration_url"
    t.integer  "category_id"
    t.text     "body"
    t.boolean  "published",        :default => false
    t.boolean  "deleted",          :default => false
    t.boolean  "archived",         :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_block_versions", :force => true do |t|
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "type"
    t.string   "name"
    t.integer  "attachment_id"
    t.integer  "attachment_version"
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "file_block_versions", ["original_record_id"], :name => "index_file_block_versions_on_file_block_id"
  add_index "file_block_versions", ["version"], :name => "index_file_block_versions_on_version"

  create_table "file_blocks", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",       :default => 0
    t.string   "type"
    t.string   "name"
    t.integer  "attachment_id"
    t.integer  "attachment_version"
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "file_blocks", ["deleted"], :name => "index_file_blocks_on_deleted"
  add_index "file_blocks", ["type"], :name => "index_file_blocks_on_type"

  create_table "group_permissions", :force => true do |t|
    t.integer "group_id"
    t.integer "permission_id"
  end

  add_index "group_permissions", ["group_id", "permission_id"], :name => "index_group_permissions_on_group_id_and_permission_id"
  add_index "group_permissions", ["group_id"], :name => "index_group_permissions_on_group_id"
  add_index "group_permissions", ["permission_id"], :name => "index_group_permissions_on_permission_id"

  create_table "group_sections", :force => true do |t|
    t.integer "group_id"
    t.integer "section_id"
  end

  add_index "group_sections", ["group_id"], :name => "index_group_sections_on_group_id"
  add_index "group_sections", ["section_id"], :name => "index_group_sections_on_section_id"

  create_table "group_type_permissions", :force => true do |t|
    t.integer "group_type_id"
    t.integer "permission_id"
  end

  create_table "group_types", :force => true do |t|
    t.string   "name"
    t.boolean  "guest",      :default => false
    t.boolean  "cms_access", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_types", ["cms_access"], :name => "index_group_types_on_cms_access"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.integer  "group_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["code"], :name => "index_groups_on_code"
  add_index "groups", ["group_type_id"], :name => "index_groups_on_group_type_id"

  create_table "html_block_versions", :force => true do |t|
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "name"
    t.text     "content",            :limit => 16777215
    t.boolean  "published",                              :default => false
    t.boolean  "deleted",                                :default => false
    t.boolean  "archived",                               :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "html_block_versions", ["original_record_id"], :name => "index_html_block_versions_on_html_block_id"
  add_index "html_block_versions", ["version"], :name => "index_html_block_versions_on_version"

  create_table "html_blocks", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",                      :default => 0
    t.string   "name"
    t.text     "content",       :limit => 16777215
    t.boolean  "published",                         :default => false
    t.boolean  "deleted",                           :default => false
    t.boolean  "archived",                          :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "html_blocks", ["deleted"], :name => "index_html_blocks_on_deleted"

  create_table "link_versions", :force => true do |t|
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "name"
    t.string   "url"
    t.boolean  "new_window",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "links", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",   :default => 0
    t.string   "name"
    t.string   "url"
    t.boolean  "new_window",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",      :default => false
    t.boolean  "deleted",        :default => false
    t.boolean  "archived",       :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "latest_version"
  end

  create_table "news_article_versions", :force => true do |t|
    t.integer  "news_article_id"
    t.integer  "version"
    t.string   "name"
    t.string   "slug"
    t.datetime "release_date"
    t.integer  "category_id"
    t.integer  "attachment_id"
    t.integer  "attachment_version"
    t.text     "summary"
    t.text     "body"
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "news_articles", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",       :default => 0
    t.string   "name"
    t.string   "slug"
    t.datetime "release_date"
    t.integer  "category_id"
    t.integer  "attachment_id"
    t.integer  "attachment_version"
    t.text     "summary"
    t.text     "body"
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_route_options", :force => true do |t|
    t.integer  "page_route_id"
    t.string   "type"
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_routes", :force => true do |t|
    t.string   "name"
    t.string   "pattern"
    t.integer  "page_id"
    t.text     "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_versions", :force => true do |t|
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "name"
    t.string   "title"
    t.string   "path"
    t.string   "template_file_name"
    t.text     "description"
    t.text     "keywords"
    t.string   "language"
    t.boolean  "cacheable",          :default => false
    t.boolean  "hidden",             :default => false
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_versions", ["original_record_id"], :name => "index_page_versions_on_page_id"

  create_table "pages", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",       :default => 0
    t.string   "name"
    t.string   "title"
    t.string   "path"
    t.string   "template_file_name"
    t.text     "description"
    t.text     "keywords"
    t.string   "language"
    t.boolean  "cacheable",          :default => false
    t.boolean  "hidden",             :default => false
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "latest_version"
  end

  add_index "pages", ["deleted"], :name => "index_pages_on_deleted"
  add_index "pages", ["path"], :name => "index_pages_on_path"
  add_index "pages", ["version"], :name => "index_pages_on_version"

  create_table "permissions", :force => true do |t|
    t.string   "name"
    t.string   "full_name"
    t.string   "description"
    t.string   "for_module"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portlet_attributes", :force => true do |t|
    t.integer "portlet_id"
    t.string  "name"
    t.text    "value"
  end

  add_index "portlet_attributes", ["portlet_id"], :name => "index_portlet_attributes_on_portlet_id"

  create_table "portlets", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.boolean  "archived",      :default => false
    t.boolean  "deleted",       :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "portlets", ["name"], :name => "index_portlets_on_name"

  create_table "product_versions", :force => true do |t|
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "name"
    t.integer  "price"
    t.integer  "category_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "products", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",  :default => 0
    t.string   "name"
    t.integer  "price"
    t.integer  "category_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "published",     :default => false
    t.boolean  "deleted",       :default => false
    t.boolean  "archived",      :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "redirects", :force => true do |t|
    t.string   "from_path"
    t.string   "to_path"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "redirects", ["from_path"], :name => "index_redirects_on_from_path"

  create_table "section_nodes", :force => true do |t|
    t.string   "node_type"
    t.integer  "node_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
  end

  add_index "section_nodes", ["ancestry"], :name => "index_section_nodes_on_ancestry"
  add_index "section_nodes", ["node_type"], :name => "index_section_nodes_on_node_type"

  create_table "sections", :force => true do |t|
    t.string   "name"
    t.string   "path"
    t.boolean  "root",       :default => false
    t.boolean  "hidden",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sections", ["path"], :name => "index_sections_on_path"

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "domain"
    t.boolean  "the_default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "slider_versions", :force => true do |t|
    t.integer  "slider_id"
    t.integer  "version"
    t.string   "name"
    t.string   "slider_headline"
    t.string   "slider_details"
    t.string   "slider_link"
    t.string   "slider_link_url"
    t.integer  "attachment_id"
    t.integer  "attachment_version"
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sliders", :force => true do |t|
    t.integer  "version"
    t.integer  "lock_version",       :default => 0
    t.string   "name"
    t.string   "slider_headline"
    t.string   "slider_details"
    t.string   "slider_link"
    t.string   "slider_link_url"
    t.integer  "attachment_id"
    t.integer  "attachment_version"
    t.boolean  "published",          :default => false
    t.boolean  "deleted",            :default => false
    t.boolean  "archived",           :default => false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "taggable_version"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", :force => true do |t|
    t.integer  "assigned_by_id"
    t.integer  "assigned_to_id"
    t.integer  "page_id"
    t.text     "comment"
    t.date     "due_date"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tasks", ["assigned_to_id"], :name => "index_tasks_on_assigned_to_id"
  add_index "tasks", ["completed_at"], :name => "index_tasks_on_completed_at"
  add_index "tasks", ["page_id"], :name => "index_tasks_on_page_id"

  create_table "timelines", :force => true do |t|
    t.string   "username"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_group_memberships", :force => true do |t|
    t.integer "user_id"
    t.integer "group_id"
  end

  add_index "user_group_memberships", ["group_id"], :name => "index_user_group_memberships_on_group_id"
  add_index "user_group_memberships", ["user_id"], :name => "index_user_group_memberships_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "first_name",                :limit => 40
    t.string   "last_name",                 :limit => 40
    t.string   "email",                     :limit => 40
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.string   "reset_token"
  end

  add_index "users", ["expires_at"], :name => "index_users_on_expires_at"
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
