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

  create_table "catalog_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "original_record_id"
    t.integer  "version"
    t.boolean  "published",          default: false
    t.boolean  "deleted",            default: false
    t.boolean  "archived",           default: false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "catalogs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "version"
    t.integer  "lock_version",  default: 0
    t.boolean  "published",     default: false
    t.boolean  "deleted",       default: false
    t.boolean  "archived",      default: false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "cms_attachment_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "data_file_name"
    t.string   "data_file_path"
    t.string   "file_location"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.string   "data_fingerprint"
    t.string   "attachable_type"
    t.string   "attachment_name"
    t.integer  "attachable_id"
    t.integer  "attachable_version"
    t.string   "cardinality"
    t.integer  "original_record_id"
    t.integer  "version"
    t.boolean  "published",          default: false
    t.boolean  "deleted",            default: false
    t.boolean  "archived",           default: false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["original_record_id"], name: "index_cms_attachment_versions_on_original_record_id", using: :btree
  end

  create_table "cms_attachments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "data_file_name"
    t.string   "data_file_path"
    t.string   "file_location"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.string   "data_fingerprint"
    t.string   "attachable_type"
    t.string   "attachment_name"
    t.integer  "attachable_id"
    t.integer  "attachable_version"
    t.string   "cardinality"
    t.integer  "version"
    t.integer  "lock_version",       default: 0
    t.boolean  "published",          default: false
    t.boolean  "deleted",            default: false
    t.boolean  "archived",           default: false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "cms_categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "category_type_id"
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "cms_category_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cms_connectors", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "page_id"
    t.integer  "page_version"
    t.integer  "connectable_id"
    t.string   "connectable_type"
    t.integer  "connectable_version"
    t.string   "container"
    t.integer  "position"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["connectable_type"], name: "index_cms_connectors_on_connectable_type", using: :btree
    t.index ["connectable_version"], name: "index_cms_connectors_on_connectable_version", using: :btree
    t.index ["page_id"], name: "index_cms_connectors_on_page_id", using: :btree
    t.index ["page_version"], name: "index_cms_connectors_on_page_version", using: :btree
  end

  create_table "cms_dynamic_view_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "type"
    t.string   "name"
    t.string   "format"
    t.string   "handler"
    t.text     "body",               limit: 65535
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "original_record_id"
    t.integer  "version"
    t.boolean  "published",                        default: false
    t.boolean  "deleted",                          default: false
    t.boolean  "archived",                         default: false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "path"
    t.string   "locale",                           default: "en"
    t.boolean  "partial",                          default: false
  end

  create_table "cms_dynamic_views", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "type"
    t.string   "name"
    t.string   "format"
    t.string   "handler"
    t.text     "body",          limit: 65535
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "version"
    t.integer  "lock_version",                default: 0
    t.boolean  "published",                   default: false
    t.boolean  "deleted",                     default: false
    t.boolean  "archived",                    default: false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "path"
    t.string   "locale",                      default: "en"
    t.boolean  "partial",                     default: false
  end

  create_table "cms_email_messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "sender"
    t.text     "recipients",   limit: 65535
    t.text     "subject",      limit: 65535
    t.text     "cc",           limit: 65535
    t.text     "bcc",          limit: 65535
    t.text     "body",         limit: 65535
    t.string   "content_type"
    t.datetime "delivered_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "cms_file_block_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "type"
    t.string   "name"
    t.integer  "attachment_id"
    t.integer  "attachment_version"
    t.integer  "original_record_id"
    t.integer  "version"
    t.boolean  "published",          default: false
    t.boolean  "deleted",            default: false
    t.boolean  "archived",           default: false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["original_record_id"], name: "index_cms_file_block_versions_on_original_record_id", using: :btree
    t.index ["version"], name: "index_cms_file_block_versions_on_version", using: :btree
  end

  create_table "cms_file_blocks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "type"
    t.string   "name"
    t.integer  "attachment_id"
    t.integer  "attachment_version"
    t.integer  "version"
    t.integer  "lock_version",       default: 0
    t.boolean  "published",          default: false
    t.boolean  "deleted",            default: false
    t.boolean  "archived",           default: false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.index ["deleted"], name: "index_cms_file_blocks_on_deleted", using: :btree
    t.index ["type"], name: "index_cms_file_blocks_on_type", using: :btree
  end

  create_table "cms_form_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "data_columns", limit: 65535
    t.integer  "form_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "cms_form_fields", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "form_id"
    t.string   "label"
    t.string   "name"
    t.string   "field_type"
    t.boolean  "required"
    t.integer  "position"
    t.text     "instructions",  limit: 65535
    t.text     "default_value", limit: 65535
    t.text     "choices",       limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["form_id", "name"], name: "index_cms_form_fields_on_form_id_and_name", unique: true, using: :btree
  end

  create_table "cms_form_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "description",           limit: 65535
    t.string   "confirmation_behavior"
    t.text     "confirmation_text",     limit: 65535
    t.string   "confirmation_redirect"
    t.string   "notification_email"
    t.integer  "original_record_id"
    t.integer  "version"
    t.boolean  "published",                           default: false
    t.boolean  "deleted",                             default: false
    t.boolean  "archived",                            default: false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "cms_forms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "description",           limit: 65535
    t.string   "confirmation_behavior"
    t.text     "confirmation_text",     limit: 65535
    t.string   "confirmation_redirect"
    t.string   "notification_email"
    t.integer  "version"
    t.integer  "lock_version",                        default: 0
    t.boolean  "published",                           default: false
    t.boolean  "deleted",                             default: false
    t.boolean  "archived",                            default: false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "cms_group_permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "group_id"
    t.integer "permission_id"
    t.index ["group_id", "permission_id"], name: "index_cms_group_permissions_on_group_id_and_permission_id", using: :btree
    t.index ["group_id"], name: "index_cms_group_permissions_on_group_id", using: :btree
    t.index ["permission_id"], name: "index_cms_group_permissions_on_permission_id", using: :btree
  end

  create_table "cms_group_sections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "group_id"
    t.integer "section_id"
    t.index ["group_id"], name: "index_cms_group_sections_on_group_id", using: :btree
    t.index ["section_id"], name: "index_cms_group_sections_on_section_id", using: :btree
  end

  create_table "cms_group_type_permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "group_type_id"
    t.integer "permission_id"
  end

  create_table "cms_group_types", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.boolean  "guest",      default: false
    t.boolean  "cms_access", default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["cms_access"], name: "index_cms_group_types_on_cms_access", using: :btree
  end

  create_table "cms_groups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "code"
    t.integer  "group_type_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["code"], name: "index_cms_groups_on_code", using: :btree
    t.index ["group_type_id"], name: "index_cms_groups_on_group_type_id", using: :btree
  end

  create_table "cms_html_block_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "content",            limit: 16777215
    t.integer  "original_record_id"
    t.integer  "version"
    t.string   "name"
    t.boolean  "published",                           default: false
    t.boolean  "deleted",                             default: false
    t.boolean  "archived",                            default: false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.index ["original_record_id"], name: "index_cms_html_block_versions_on_original_record_id", using: :btree
    t.index ["version"], name: "index_cms_html_block_versions_on_version", using: :btree
  end

  create_table "cms_html_blocks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "content",       limit: 16777215
    t.integer  "version"
    t.integer  "lock_version",                   default: 0
    t.string   "name"
    t.boolean  "published",                      default: false
    t.boolean  "deleted",                        default: false
    t.boolean  "archived",                       default: false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.index ["deleted"], name: "index_cms_html_blocks_on_deleted", using: :btree
  end

  create_table "cms_link_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "url"
    t.boolean  "new_window",         default: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "original_record_id"
    t.integer  "version"
    t.boolean  "published",          default: false
    t.boolean  "deleted",            default: false
    t.boolean  "archived",           default: false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "cms_links", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "url"
    t.boolean  "new_window",     default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "version"
    t.integer  "lock_version",   default: 0
    t.boolean  "published",      default: false
    t.boolean  "deleted",        default: false
    t.boolean  "archived",       default: false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "latest_version"
  end

  create_table "cms_page_route_options", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "page_route_id"
    t.string   "type"
    t.string   "name"
    t.string   "value"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "cms_page_routes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "pattern"
    t.integer  "page_id"
    t.text     "code",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "cms_page_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "title"
    t.string   "path"
    t.string   "template_file_name"
    t.text     "description",        limit: 65535
    t.text     "keywords",           limit: 65535
    t.string   "language"
    t.boolean  "cacheable",                        default: false
    t.boolean  "hidden",                           default: false
    t.integer  "original_record_id"
    t.integer  "version"
    t.boolean  "published",                        default: false
    t.boolean  "deleted",                          default: false
    t.boolean  "archived",                         default: false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.index ["original_record_id"], name: "index_cms_page_versions_on_original_record_id", using: :btree
  end

  create_table "cms_pages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "title"
    t.string   "path"
    t.string   "template_file_name"
    t.text     "description",        limit: 65535
    t.text     "keywords",           limit: 65535
    t.string   "language"
    t.boolean  "cacheable",                        default: false
    t.boolean  "hidden",                           default: false
    t.integer  "version"
    t.integer  "lock_version",                     default: 0
    t.boolean  "published",                        default: false
    t.boolean  "deleted",                          default: false
    t.boolean  "archived",                         default: false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "latest_version"
    t.index ["deleted"], name: "index_cms_pages_on_deleted", using: :btree
    t.index ["path"], name: "index_cms_pages_on_path", using: :btree
    t.index ["version"], name: "index_cms_pages_on_version", using: :btree
  end

  create_table "cms_permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "full_name"
    t.string   "description"
    t.string   "for_module"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "cms_portlet_attributes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "portlet_id"
    t.string  "name"
    t.text    "value",      limit: 65535
    t.index ["portlet_id"], name: "index_cms_portlet_attributes_on_portlet_id", using: :btree
  end

  create_table "cms_portlets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "type"
    t.string   "name"
    t.boolean  "archived",      default: false
    t.boolean  "deleted",       default: false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["name"], name: "index_cms_portlets_on_name", using: :btree
  end

  create_table "cms_redirects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "from_path"
    t.string   "to_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_path"], name: "index_cms_redirects_on_from_path", using: :btree
  end

  create_table "cms_section_nodes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "node_type"
    t.integer  "node_id"
    t.integer  "position"
    t.string   "ancestry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "slug"
    t.index ["ancestry"], name: "index_cms_section_nodes_on_ancestry", using: :btree
    t.index ["node_type"], name: "index_cms_section_nodes_on_node_type", using: :btree
  end

  create_table "cms_sections", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "path"
    t.boolean  "root",       default: false
    t.boolean  "hidden",     default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["path"], name: "index_cms_sections_on_path", using: :btree
  end

  create_table "cms_sites", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "domain"
    t.boolean  "the_default"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "cms_taggings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "taggable_version"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "cms_tags", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cms_tasks", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "assigned_by_id"
    t.integer  "assigned_to_id"
    t.integer  "page_id"
    t.text     "comment",        limit: 65535
    t.date     "due_date"
    t.datetime "completed_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["assigned_to_id"], name: "index_cms_tasks_on_assigned_to_id", using: :btree
    t.index ["completed_at"], name: "index_cms_tasks_on_completed_at", using: :btree
    t.index ["page_id"], name: "index_cms_tasks_on_page_id", using: :btree
  end

  create_table "cms_user_group_memberships", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_cms_user_group_memberships_on_group_id", using: :btree
    t.index ["user_id"], name: "index_cms_user_group_memberships_on_user_id", using: :btree
  end

  create_table "cms_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "login",                  limit: 40
    t.string   "first_name",             limit: 40
    t.string   "last_name",              limit: 40
    t.string   "email",                  limit: 40
    t.string   "salt",                   limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at"
    t.datetime "remember_created_at"
    t.string   "reset_password_token"
    t.string   "encrypted_password",                   default: "",          null: false
    t.datetime "reset_password_sent_at"
    t.string   "type",                                 default: "Cms::User"
    t.string   "source"
    t.text     "external_data",          limit: 65535
    t.index ["email"], name: "index_cms_users_on_email", unique: true, using: :btree
    t.index ["expires_at"], name: "index_cms_users_on_expires_at", using: :btree
    t.index ["login"], name: "index_cms_users_on_login", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_cms_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "deprecated_input_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "content",            limit: 65535
    t.text     "template",           limit: 65535
    t.string   "template_handler"
    t.integer  "category_id"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "original_record_id"
    t.integer  "version"
    t.boolean  "published",                        default: false
    t.boolean  "deleted",                          default: false
    t.boolean  "archived",                         default: false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.index ["category_id"], name: "index_deprecated_input_versions_on_category_id", using: :btree
  end

  create_table "deprecated_inputs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "content",          limit: 65535
    t.text     "template",         limit: 65535
    t.string   "template_handler"
    t.integer  "category_id"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "version"
    t.integer  "lock_version",                   default: 0
    t.boolean  "published",                      default: false
    t.boolean  "deleted",                        default: false
    t.boolean  "archived",                       default: false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.index ["category_id"], name: "index_deprecated_inputs_on_category_id", using: :btree
  end

  create_table "product_versions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "price"
    t.integer  "category_id"
    t.boolean  "on_special"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "original_record_id"
    t.integer  "version"
    t.boolean  "published",          default: false
    t.boolean  "deleted",            default: false
    t.boolean  "archived",           default: false
    t.string   "version_comment"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

  create_table "products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.integer  "price"
    t.integer  "category_id"
    t.boolean  "on_special"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "version"
    t.integer  "lock_version",  default: 0
    t.boolean  "published",     default: false
    t.boolean  "deleted",       default: false
    t.boolean  "archived",      default: false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
  end

end
