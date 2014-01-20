class Browsercms400 < ActiveRecord::Migration

  def up
    apply_cms_namespace_to_all_core_tables

    add_column :cms_section_nodes, :slug, :string
    add_content_column :cms_dynamic_views, :path, :string
    add_content_column :cms_dynamic_views, :locale, :string, default: 'en'
    add_content_column :cms_dynamic_views, :partial, :boolean, default: false

    Cms::PageTemplate.all.find_each do |pt|
      pt.path = "layout/templates/#{pt.name}"
      pt.locale = "en"
      pt.save!
    end

    Cms::PagePartial.all.find_each do |pp|
      pp.path = "partials/#{pp.name}"
      pp.locale = "en"
      pp.partial = true
      pp.save!
    end

    drop_table :cms_content_type_groups
    drop_table :cms_content_types

    create_content_table :cms_forms do |t|
      t.string :name
      t.text :description
      t.string :confirmation_behavior
      t.text :confirmation_text
      t.string :confirmation_redirect
      t.string :notification_email
    end

    create_table :cms_form_fields do |t|
      t.integer :form_id
      t.string :label
      t.string :name
      t.string :field_type
      t.boolean :required
      t.integer :position
      t.text :instructions
      t.text :default_value
      t.text :choices
      t.timestamps
    end

    # Field names should be unique per form
    add_index :cms_form_fields, [:form_id, :name], :unique => true

    create_table :cms_form_entries do |t|
      t.text :data_columns
      t.integer :form_id
      t.timestamps
    end

    add_devise_users
    remove_reset_password_portlet
    add_external_users
  end



  private

  def add_external_users
    change_table :cms_users do |t|
      t.column :type, :string, default: 'Cms::User'
      t.column :source, :string
      t.text :external_data
    end
  end

  def remove_reset_password_portlet
    Cms::Portlet.connection.execute("UPDATE cms_portlets SET type = 'DeprecatedPlaceholder' WHERE type = 'ResetPasswordPortlet'")
  end

  def add_devise_users
    change_table(:cms_users) do |t|
      t.string :encrypted_password, :null => false, :default => ""
      t.rename   :reset_token, :reset_password_token
      t.datetime :reset_password_sent_at
      t.rename :remember_token_expires_at, :remember_created_at
      t.remove :remember_token
      t.remove :crypted_password
    end

    add_index :cms_users, :email,                :unique => true
    add_index :cms_users, :reset_password_token, :unique => true
  end
  # In 4.x, all core tables MUST start with cms_. See https://github.com/browsermedia/browsercms/issues/639
  def apply_cms_namespace_to_all_core_tables
    unversioned_tables.each do |table_name|
      if (needs_namespacing(table_name))
        rename_table table_name, cms_(table_name)
      end
    end

    versioned_tables.each do |table_name|
      if (needs_namespacing(table_name))
        rename_table table_name, cms_(table_name)
        rename_table versioned_(table_name), cms_(versioned_(table_name))
      end
    end
  end

  # All tables that aren't versioned. (I.e. two tables)
  def unversioned_tables
    [:categories, :category_types, :connectors, :content_types, :content_type_groups, :email_messages, :group_permissions, :group_sections, :group_type_permissions, :group_types, :groups, :page_route_options, :page_routes, :permissions, :portlet_attributes, :portlets, :redirects, :section_nodes, :sections, :sites, :taggings, :tags, :tasks, :user_group_memberships, :users]
  end

  def versioned_tables
    [:attachments, :dynamic_views, :file_blocks, :html_blocks, :links, :pages]
  end

  def needs_namespacing(table_name)
    table_exists?(table_name) && !table_exists?(cms_(table_name))
  end
end
