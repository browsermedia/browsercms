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

ActiveRecord::Schema.define(version: 20130924162315) do

  create_table "catalog_versions", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "original_record_id", limit: 4
    t.integer  "version",            limit: 4
    t.boolean  "published",                      default: false
    t.boolean  "deleted",                        default: false
    t.boolean  "archived",                       default: false
    t.string   "version_comment",    limit: 255
    t.integer  "created_by_id",      limit: 4
    t.integer  "updated_by_id",      limit: 4
  end

  create_table "catalogs", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "version",       limit: 4
    t.integer  "lock_version",  limit: 4,   default: 0
    t.boolean  "published",                 default: false
    t.boolean  "deleted",                   default: false
    t.boolean  "archived",                  default: false
    t.integer  "created_by_id", limit: 4
    t.integer  "updated_by_id", limit: 4
  end

  create_table "cms_attachment_versions", force: :cascade do |t|
    t.string   "data_file_name",     limit: 255
    t.string   "data_file_path",     limit: 255
    t.string   "file_location",      limit: 255
    t.string   "data_content_type",  limit: 255
    t.integer  "data_file_size",     limit: 4
    t.string   "data_fingerprint",   limit: 255
    t.string   "attachable_type",    limit: 255
    t.string   "attachment_name",    limit: 255
    t.integer  "attachable_id",      limit: 4
    t.integer  "attachable_version", limit: 4
    t.string   "cardinality",        limit: 255
    t.integer  "original_record_id", limit: 4
    t.integer  "version",            limit: 4
    t.boolean  "published",                      default: false
    t.boolean  "deleted",                        default: false
    t.boolean  "archived",                       default: false
    t.string   "version_comment",    limit: 255
    t.integer  "created_by_id",      limit: 4
    t.integer  "updated_by_id",      limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "cms_attachment_versions", ["original_record_id"], name: "index_cms_attachment_versions_on_original_record_id", using: :btree

  create_table "cms_attachments", force: :cascade do |t|
    t.string   "data_file_name",     limit: 255
    t.string   "data_file_path",     limit: 255
    t.string   "file_location",      limit: 255
    t.string   "data_content_type",  limit: 255
    t.integer  "data_file_size",     limit: 4
    t.string   "data_fingerprint",   limit: 255
    t.string   "attachable_type",    limit: 255
    t.string   "attachment_name",    limit: 255
    t.integer  "attachable_id",      limit: 4
    t.integer  "attachable_version", limit: 4
    t.string   "cardinality",        limit: 255
    t.integer  "version",            limit: 4
    t.integer  "lock_version",       limit: 4,   default: 0
    t.boolean  "published",                      default: false
    t.boolean  "deleted",                        default: false
    t.boolean  "archived",                       default: false
    t.integer  "created_by_id",      limit: 4
    t.integer  "updated_by_id",      limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  create_table "cms_categories", force: :cascade do |t|
    t.integer  "category_type_id", limit: 4
    t.integer  "parent_id",        limit: 4
    t.string   "name",             limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "cms_category_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "cms_connectors", force: :cascade do |t|
    t.integer  "page_id",             limit: 4
    t.integer  "page_version",        limit: 4
    t.integer  "connectable_id",      limit: 4
    t.string   "connectable_type",    limit: 255
    t.integer  "connectable_version", limit: 4
    t.string   "container",           limit: 255
    t.integer  "position",            limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "cms_connectors", ["connectable_type"], name: "index_cms_connectors_on_connectable_type", using: :btree
  add_index "cms_connectors", ["connectable_version"], name: "index_cms_connectors_on_connectable_version", using: :btree
  add_index "cms_connectors", ["page_id"], name: "index_cms_connectors_on_page_id", using: :btree
  add_index "cms_connectors", ["page_version"], name: "index_cms_connectors_on_page_version", using: :btree

  create_table "cms_dynamic_view_versions", force: :cascade do |t|
    t.string   "type",               limit: 255
    t.string   "name",               limit: 255
    t.string   "format",             limit: 255
    t.string   "handler",            limit: 255
    t.text     "body",               limit: 65535
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "original_record_id", limit: 4
    t.integer  "version",            limit: 4
    t.boolean  "published",                        default: false
    t.boolean  "deleted",                          default: false
    t.boolean  "archived",                         default: false
    t.string   "version_comment",    limit: 255
    t.integer  "created_by_id",      limit: 4
    t.integer  "updated_by_id",      limit: 4
    t.string   "path",               limit: 255
    t.string   "locale",             limit: 255,   default: "en"
    t.boolean  "partial",                          default: false
  end

  create_table "cms_dynamic_views", force: :cascade do |t|
    t.string   "type",          limit: 255
    t.string   "name",          limit: 255
    t.string   "format",        limit: 255
    t.string   "handler",       limit: 255
    t.text     "body",          limit: 65535
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "version",       limit: 4
    t.integer  "lock_version",  limit: 4,     default: 0
    t.boolean  "published",                   default: false
    t.boolean  "deleted",                     default: false
    t.boolean  "archived",                    default: false
    t.integer  "created_by_id", limit: 4
    t.integer  "updated_by_id", limit: 4
    t.string   "path",          limit: 255
    t.string   "locale",        limit: 255,   default: "en"
    t.boolean  "partial",                     default: false
  end

  create_table "cms_email_messages", force: :cascade do |t|
    t.string   "sender",       limit: 255
    t.text     "recipients",   limit: 65535
    t.text     "subject",      limit: 65535
    t.text     "cc",           limit: 65535
    t.text     "bcc",          limit: 65535
    t.text     "body",         limit: 65535
    t.string   "content_type", limit: 255
    t.datetime "delivered_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "cms_file_block_versions", force: :cascade do |t|
    t.string   "type",               limit: 255
    t.string   "name",               limit: 255
    t.integer  "attachment_id",      limit: 4
    t.integer  "attachment_version", limit: 4
    t.integer  "original_record_id", limit: 4
    t.integer  "version",            limit: 4
    t.boolean  "published",                      default: false
    t.boolean  "deleted",                        default: false
    t.boolean  "archived",                       default: false
    t.string   "version_comment",    limit: 255
    t.integer  "created_by_id",      limit: 4
    t.integer  "updated_by_id",      limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "cms_file_block_versions", ["original_record_id"], name: "index_cms_file_block_versions_on_original_record_id", using: :btree
  add_index "cms_file_block_versions", ["version"], name: "index_cms_file_block_versions_on_version", using: :btree

  create_table "cms_file_blocks", force: :cascade do |t|
    t.string   "type",               limit: 255
    t.string   "name",               limit: 255
    t.integer  "attachment_id",      limit: 4
    t.integer  "attachment_version", limit: 4
    t.integer  "version",            limit: 4
    t.integer  "lock_version",       limit: 4,   default: 0
    t.boolean  "published",                      default: false
    t.boolean  "deleted",                        default: false
    t.boolean  "archived",                       default: false
    t.integer  "created_by_id",      limit: 4
    t.integer  "updated_by_id",      limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "cms_file_blocks", ["deleted"], name: "index_cms_file_blocks_on_deleted", using: :btree
  add_index "cms_file_blocks", ["type"], name: "index_cms_file_blocks_on_type", using: :btree

  create_table "cms_form_entries", force: :cascade do |t|
    t.text     "data_columns", limit: 65535
    t.integer  "form_id",      limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "cms_form_fields", force: :cascade do |t|
    t.integer  "form_id",       limit: 4
    t.string   "label",         limit: 255
    t.string   "name",          limit: 255
    t.string   "field_type",    limit: 255
    t.boolean  "required"
    t.integer  "position",      limit: 4
    t.text     "instructions",  limit: 65535
    t.text     "default_value", limit: 65535
    t.text     "choices",       limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "cms_form_fields", ["form_id", "name"], name: "index_cms_form_fields_on_form_id_and_name", unique: true, using: :btree

  create_table "cms_form_versions", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.text     "description",           limit: 65535
    t.string   "confirmation_behavior", limit: 255
    t.text     "confirmation_text",     limit: 65535
    t.string   "confirmation_redirect", limit: 255
    t.string   "notification_email",    limit: 255
    t.integer  "original_record_id",    limit: 4
    t.integer  "version",               limit: 4
    t.boolean  "published",                           default: false
    t.boolean  "deleted",                             default: false
    t.boolean  "archived",                            default: false
    t.string   "version_comment",       limit: 255
    t.integer  "created_by_id",         limit: 4
    t.integer  "updated_by_id",         limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "cms_forms", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.text     "description",           limit: 65535
    t.string   "confirmation_behavior", limit: 255
    t.text     "confirmation_text",     limit: 65535
    t.string   "confirmation_redirect", limit: 255
    t.string   "notification_email",    limit: 255
    t.integer  "version",               limit: 4
    t.integer  "lock_version",          limit: 4,     default: 0
    t.boolean  "published",                           default: false
    t.boolean  "deleted",                             default: false
    t.boolean  "archived",                            default: false
    t.integer  "created_by_id",         limit: 4
    t.integer  "updated_by_id",         limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "cms_group_permissions", force: :cascade do |t|
    t.integer "group_id",      limit: 4
    t.integer "permission_id", limit: 4
  end

  add_index "cms_group_permissions", ["group_id", "permission_id"], name: "index_cms_group_permissions_on_group_id_and_permission_id", using: :btree
  add_index "cms_group_permissions", ["group_id"], name: "index_cms_group_permissions_on_group_id", using: :btree
  add_index "cms_group_permissions", ["permission_id"], name: "index_cms_group_permissions_on_permission_id", using: :btree

  create_table "cms_group_sections", force: :cascade do |t|
    t.integer "group_id",   limit: 4
    t.integer "section_id", limit: 4
  end

  add_index "cms_group_sections", ["group_id"], name: "index_cms_group_sections_on_group_id", using: :btree
  add_index "cms_group_sections", ["section_id"], name: "index_cms_group_sections_on_section_id", using: :btree

  create_table "cms_group_type_permissions", force: :cascade do |t|
    t.integer "group_type_id", limit: 4
    t.integer "permission_id", limit: 4
  end

  create_table "cms_group_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.boolean  "guest",                  default: false
    t.boolean  "cms_access",             default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "cms_group_types", ["cms_access"], name: "index_cms_group_types_on_cms_access", using: :btree

  create_table "cms_groups", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "code",          limit: 255
    t.integer  "group_type_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "cms_groups", ["code"], name: "index_cms_groups_on_code", using: :btree
  add_index "cms_groups", ["group_type_id"], name: "index_cms_groups_on_group_type_id", using: :btree

  create_table "cms_html_block_versions", force: :cascade do |t|
    t.text     "content",            limit: 16777215
    t.integer  "original_record_id", limit: 4
    t.integer  "version",            limit: 4
    t.string   "name",               limit: 255
    t.boolean  "published",                           default: false
    t.boolean  "deleted",                             default: false
    t.boolean  "archived",                            default: false
    t.string   "version_comment",    limit: 255
    t.integer  "created_by_id",      limit: 4
    t.integer  "updated_by_id",      limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "cms_html_block_versions", ["original_record_id"], name: "index_cms_html_block_versions_on_original_record_id", using: :btree
  add_index "cms_html_block_versions", ["version"], name: "index_cms_html_block_versions_on_version", using: :btree

  create_table "cms_html_blocks", force: :cascade do |t|
    t.text     "content",       limit: 16777215
    t.integer  "version",       limit: 4
    t.integer  "lock_version",  limit: 4,        default: 0
    t.string   "name",          limit: 255
    t.boolean  "published",                      default: false
    t.boolean  "deleted",                        default: false
    t.boolean  "archived",                       default: false
    t.integer  "created_by_id", limit: 4
    t.integer  "updated_by_id", limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "cms_html_blocks", ["deleted"], name: "index_cms_html_blocks_on_deleted", using: :btree

  create_table "cms_link_versions", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "url",                limit: 255
    t.boolean  "new_window",                     default: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "original_record_id", limit: 4
    t.integer  "version",            limit: 4
    t.boolean  "published",                      default: false
    t.boolean  "deleted",                        default: false
    t.boolean  "archived",                       default: false
    t.string   "version_comment",    limit: 255
    t.integer  "created_by_id",      limit: 4
    t.integer  "updated_by_id",      limit: 4
  end

  create_table "cms_links", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "url",            limit: 255
    t.boolean  "new_window",                 default: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "version",        limit: 4
    t.integer  "lock_version",   limit: 4,   default: 0
    t.boolean  "published",                  default: false
    t.boolean  "deleted",                    default: false
    t.boolean  "archived",                   default: false
    t.integer  "created_by_id",  limit: 4
    t.integer  "updated_by_id",  limit: 4
    t.integer  "latest_version", limit: 4
  end

  create_table "cms_page_route_options", force: :cascade do |t|
    t.integer  "page_route_id", limit: 4
    t.string   "type",          limit: 255
    t.string   "name",          limit: 255
    t.string   "value",         limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "cms_page_routes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "pattern",    limit: 255
    t.integer  "page_id",    limit: 4
    t.text     "code",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "cms_page_versions", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "title",              limit: 255
    t.string   "path",               limit: 255
    t.string   "template_file_name", limit: 255
    t.text     "description",        limit: 65535
    t.text     "keywords",           limit: 65535
    t.string   "language",           limit: 255
    t.boolean  "cacheable",                        default: false
    t.boolean  "hidden",                           default: false
    t.integer  "original_record_id", limit: 4
    t.integer  "version",            limit: 4
    t.boolean  "published",                        default: false
    t.boolean  "deleted",                          default: false
    t.boolean  "archived",                         default: false
    t.string   "version_comment",    limit: 255
    t.integer  "created_by_id",      limit: 4
    t.integer  "updated_by_id",      limit: 4
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "cms_page_versions", ["original_record_id"], name: "index_cms_page_versions_on_original_record_id", using: :btree

  create_table "cms_pages", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "title",              limit: 255
    t.string   "path",               limit: 255
    t.string   "template_file_name", limit: 255
    t.text     "description",        limit: 65535
    t.text     "keywords",           limit: 65535
    t.string   "language",           limit: 255
    t.boolean  "cacheable",                        default: false
    t.boolean  "hidden",                           default: false
    t.integer  "version",            limit: 4
    t.integer  "lock_version",       limit: 4,     default: 0
    t.boolean  "published",                        default: false
    t.boolean  "deleted",                          default: false
    t.boolean  "archived",                         default: false
    t.integer  "created_by_id",      limit: 4
    t.integer  "updated_by_id",      limit: 4
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "latest_version",     limit: 4
  end

  add_index "cms_pages", ["deleted"], name: "index_cms_pages_on_deleted", using: :btree
  add_index "cms_pages", ["path"], name: "index_cms_pages_on_path", using: :btree
  add_index "cms_pages", ["version"], name: "index_cms_pages_on_version", using: :btree

  create_table "cms_permissions", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "full_name",   limit: 255
    t.string   "description", limit: 255
    t.string   "for_module",  limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "cms_portlet_attributes", force: :cascade do |t|
    t.integer "portlet_id", limit: 4
    t.string  "name",       limit: 255
    t.text    "value",      limit: 65535
  end

  add_index "cms_portlet_attributes", ["portlet_id"], name: "index_cms_portlet_attributes_on_portlet_id", using: :btree

  create_table "cms_portlets", force: :cascade do |t|
    t.string   "type",          limit: 255
    t.string   "name",          limit: 255
    t.boolean  "archived",                  default: false
    t.boolean  "deleted",                   default: false
    t.integer  "created_by_id", limit: 4
    t.integer  "updated_by_id", limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "cms_portlets", ["name"], name: "index_cms_portlets_on_name", using: :btree

  create_table "cms_redirects", force: :cascade do |t|
    t.string   "from_path",  limit: 255
    t.string   "to_path",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "cms_redirects", ["from_path"], name: "index_cms_redirects_on_from_path", using: :btree

  create_table "cms_section_nodes", force: :cascade do |t|
    t.string   "node_type",  limit: 255
    t.integer  "node_id",    limit: 4
    t.integer  "position",   limit: 4
    t.string   "ancestry",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "slug",       limit: 255
  end

  add_index "cms_section_nodes", ["ancestry"], name: "index_cms_section_nodes_on_ancestry", using: :btree
  add_index "cms_section_nodes", ["node_type"], name: "index_cms_section_nodes_on_node_type", using: :btree

  create_table "cms_sections", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "path",       limit: 255
    t.boolean  "root",                   default: false
    t.boolean  "hidden",                 default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "cms_sections", ["path"], name: "index_cms_sections_on_path", using: :btree

  create_table "cms_sites", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "domain",      limit: 255
    t.boolean  "the_default"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "cms_taggings", force: :cascade do |t|
    t.integer  "tag_id",           limit: 4
    t.integer  "taggable_id",      limit: 4
    t.string   "taggable_type",    limit: 255
    t.integer  "taggable_version", limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "cms_tags", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "cms_tasks", force: :cascade do |t|
    t.integer  "assigned_by_id", limit: 4
    t.integer  "assigned_to_id", limit: 4
    t.integer  "page_id",        limit: 4
    t.text     "comment",        limit: 65535
    t.date     "due_date"
    t.datetime "completed_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "cms_tasks", ["assigned_to_id"], name: "index_cms_tasks_on_assigned_to_id", using: :btree
  add_index "cms_tasks", ["completed_at"], name: "index_cms_tasks_on_completed_at", using: :btree
  add_index "cms_tasks", ["page_id"], name: "index_cms_tasks_on_page_id", using: :btree

  create_table "cms_user_group_memberships", force: :cascade do |t|
    t.integer "user_id",  limit: 4
    t.integer "group_id", limit: 4
  end

  add_index "cms_user_group_memberships", ["group_id"], name: "index_cms_user_group_memberships_on_group_id", using: :btree
  add_index "cms_user_group_memberships", ["user_id"], name: "index_cms_user_group_memberships_on_user_id", using: :btree

  create_table "cms_users", force: :cascade do |t|
    t.string   "login",                  limit: 40
    t.string   "first_name",             limit: 40
    t.string   "last_name",              limit: 40
    t.string   "email",                  limit: 40
    t.string   "salt",                   limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at"
    t.datetime "remember_created_at"
    t.string   "reset_password_token",   limit: 255
    t.string   "encrypted_password",     limit: 255,   default: "",          null: false
    t.datetime "reset_password_sent_at"
    t.string   "type",                   limit: 255,   default: "Cms::User"
    t.string   "source",                 limit: 255
    t.text     "external_data",          limit: 65535
  end

  add_index "cms_users", ["email"], name: "index_cms_users_on_email", unique: true, using: :btree
  add_index "cms_users", ["expires_at"], name: "index_cms_users_on_expires_at", using: :btree
  add_index "cms_users", ["login"], name: "index_cms_users_on_login", unique: true, using: :btree
  add_index "cms_users", ["reset_password_token"], name: "index_cms_users_on_reset_password_token", unique: true, using: :btree

  create_table "deprecated_input_versions", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.text     "content",            limit: 65535
    t.text     "template",           limit: 65535
    t.string   "template_handler",   limit: 255
    t.integer  "category_id",        limit: 4
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "original_record_id", limit: 4
    t.integer  "version",            limit: 4
    t.boolean  "published",                        default: false
    t.boolean  "deleted",                          default: false
    t.boolean  "archived",                         default: false
    t.string   "version_comment",    limit: 255
    t.integer  "created_by_id",      limit: 4
    t.integer  "updated_by_id",      limit: 4
  end

  create_table "deprecated_inputs", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.text     "content",          limit: 65535
    t.text     "template",         limit: 65535
    t.string   "template_handler", limit: 255
    t.integer  "category_id",      limit: 4
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "version",          limit: 4
    t.integer  "lock_version",     limit: 4,     default: 0
    t.boolean  "published",                      default: false
    t.boolean  "deleted",                        default: false
    t.boolean  "archived",                       default: false
    t.integer  "created_by_id",    limit: 4
    t.integer  "updated_by_id",    limit: 4
  end

  create_table "product_versions", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.integer  "price",              limit: 4
    t.integer  "category_id",        limit: 4
    t.boolean  "on_special"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "original_record_id", limit: 4
    t.integer  "version",            limit: 4
    t.boolean  "published",                      default: false
    t.boolean  "deleted",                        default: false
    t.boolean  "archived",                       default: false
    t.string   "version_comment",    limit: 255
    t.integer  "created_by_id",      limit: 4
    t.integer  "updated_by_id",      limit: 4
  end

  create_table "products", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "price",         limit: 4
    t.integer  "category_id",   limit: 4
    t.boolean  "on_special"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "version",       limit: 4
    t.integer  "lock_version",  limit: 4,   default: 0
    t.boolean  "published",                 default: false
    t.boolean  "deleted",                   default: false
    t.boolean  "archived",                  default: false
    t.integer  "created_by_id", limit: 4
    t.integer  "updated_by_id", limit: 4
  end

end
