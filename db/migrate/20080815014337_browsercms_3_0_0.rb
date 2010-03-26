class Browsercms300 < ActiveRecord::Migration
  def self.up
    create_table "cms_users", :force => true do |t|
      t.column :login,                     :string, :limit => 40
      t.column :first_name,                :string, :limit => 40
      t.column :last_name,                 :string, :limit => 40
      t.column :email,                     :string, :limit => 40
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :expires_at,                :datetime
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime
    end
    add_index :cms_users, :login, :unique => true

    create_versioned_table :cms_dynamic_views do |t|
      t.string :type
      t.string :name
      t.string :format
      t.string :handler
      t.text :body
      t.timestamps
    end

    create_versioned_table :cms_pages do |t|
      t.string :name
      t.string :title
      t.string :path
      t.string :template_file_name
      t.text :description
      t.text :keywords
      t.string :language
      t.boolean :cacheable, :default => false
      t.boolean :hidden, :default => false
    end

    create_table :cms_content_type_groups do |t|
      t.string :name
      t.timestamps
    end
    Cms::ContentTypeGroup.create!(:name => "Core")

    create_table :cms_content_types do |t|
      t.string :name
      t.belongs_to :content_type_group
      t.integer :priority, :default => 2
      t.timestamps
    end

    create_table :cms_category_types do |t|
      t.string :name
      t.timestamps
    end
    Cms::ContentType.create!(:name => "Cms::CategoryType", :group_name => "Categorization")

    create_table :cms_categories do |t|
      t.belongs_to :category_type
      t.belongs_to :parent
      t.string :name
      t.timestamps
    end
    Cms::ContentType.create!(:name => "Cms::Category", :group_name => "Categorization")

    create_table :cms_connectors do |t|
      t.integer :page_id
      t.integer :page_version
      t.integer :connectable_id
      t.string :connectable_type
      t.integer :connectable_version
      t.string :container
      t.integer :position
      t.timestamps
    end

    create_versioned_table :cms_html_blocks do |t|
      t.string :name
      t.string :content, :limit => 64.kilobytes + 1
    end
    Cms::ContentType.create!(:name => "Cms::HtmlBlock", :group_name => "Core", :priority => 1)

    create_table :cms_sections do |t|
      t.string :name
      t.string :path
      t.boolean :root, :default => false
      t.boolean :hidden, :default => false
      t.timestamps
    end

    create_table :cms_portlets do |t|
      t.string :type
      t.string :name
      t.boolean :archived, :default => false
      t.boolean :deleted, :default => false
      t.integer :created_by_id, :updated_by_id
      t.timestamps
    end
    create_table :cms_portlet_attributes do |t|
      t.integer :portlet_id
      t.string :name
      t.text :value
    end
    Cms::ContentType.create!(:name => "Cms::Portlet", :group_name => "Core", :priority => 1)

    create_table :cms_redirects do |t|
      t.string :from_path
      t.string :to_path
      t.timestamps
    end

    create_versioned_table :cms_attachments do |t|
      t.string :file_path
      t.string :file_location
      t.string :file_extension
      t.string :file_type
      t.integer :file_size
      t.timestamps
    end

    create_versioned_table :cms_file_blocks do |t|
      t.string :type
      t.string :name
      t.integer :attachment_id
      t.integer :attachment_version
    end
    Cms::ContentType.create!(:name => "Cms::FileBlock", :group_name => "Core")
    Cms::ContentType.create!(:name => "Cms::ImageBlock", :group_name => "Core")

    create_table :cms_group_types do |t|
      t.string :name
      t.boolean :guest, :default => false
      t.boolean :cms_access, :default => false
      t.timestamps
    end
    create_table :cms_groups do |t|
      t.string :name
      t.string :code
      t.integer :group_type_id
      t.timestamps
    end
    create_table :cms_user_group_memberships do |t|
      t.integer :user_id
      t.integer :group_id
    end

    create_table :cms_permissions do |t|
      t.string :name
      t.string :full_name
      t.string :description
      t.string :for_module
      t.timestamps
    end
    create_table :cms_group_permissions do |t|
      t.integer :group_id
      t.integer :permission_id
    end
    create_table :cms_group_type_permissions do |t|
      t.integer :group_type_id
      t.integer :permission_id
    end
    create_table :cms_group_sections do |t|
      t.integer :group_id
      t.integer :section_id
    end

    create_table :cms_sites do |t|
      t.string :name
      t.string :domain
      t.boolean :the_default
      t.timestamps
    end

    create_table :cms_section_nodes do |t|
      t.integer :section_id
      t.string :node_type
      t.integer :node_id
      t.integer :position
      t.timestamps
    end

    create_versioned_table :cms_links do |t|
      t.string :name
      t.string :url
      t.boolean :new_window, :default => false
      t.timestamps
    end

    create_table :cms_tags do |t|
      t.string :name
      t.timestamps
    end
    Cms::ContentType.create!(:name => "Cms::Tag", :group_name => "Categorization")

    create_table :cms_taggings do |t|
      t.integer :tag_id
      t.integer :taggable_id
      t.string :taggable_type
      t.integer :taggable_version
      t.timestamps
    end

    create_table :cms_email_messages do |t|
      t.string :sender
      t.text :recipients
      t.text :subject
      t.text :cc
      t.text :bcc
      t.text :body
      t.string :content_type
      t.datetime :delivered_at
      t.timestamps
    end

    create_table :cms_tasks do |t|
      t.integer :assigned_by_id
      t.integer :assigned_to_id
      t.integer :page_id
      t.text :comment
      t.date :due_date
      t.datetime :completed_at
      t.timestamps
    end

    create_table :cms_page_routes do |t|
      t.string :name
      t.string :pattern
      t.belongs_to :page
      t.text :code
      t.timestamps
    end                 
    create_table :cms_page_route_options do |t|
      t.belongs_to :page_route
      t.string :type
      t.string :name
      t.string :value
      t.timestamps
    end
  end

  def self.down
    drop_table :cms_page_route_options
    drop_table :cms_page_routes
    drop_table :cms_tasks
    drop_table :cms_email_messages
    drop_table :cms_taggings
    drop_table :cms_tags
    drop_versioned_table :cms_links
    drop_table :cms_section_nodes
    drop_table :cms_sites
    drop_table :cms_group_sections
    drop_table :cms_group_type_permissions
    drop_table :cms_group_permissions
    drop_table :cms_permissions
    drop_table :cms_user_group_memberships
    drop_table :cms_groups
    drop_table :cms_group_types
    drop_versioned_table :cms_file_blocks
    drop_table :cms_attachments
    drop_table :cms_redirects
    drop_table :cms_portlet_attributes
    drop_table :cms_portlets
    drop_table :cms_sections
    drop_versioned_table :cms_html_blocks
    drop_table :cms_connectors
    drop_table :cms_categories
    drop_table :cms_category_types
    drop_table :cms_content_types
    drop_table :cms_content_type_groups
    drop_versioned_table :cms_pages
    drop_versioned_table :cms_dynamic_views
    drop_table "cms_users"
  end
end
