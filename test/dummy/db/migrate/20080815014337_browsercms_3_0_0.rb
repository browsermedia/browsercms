class Browsercms300 < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
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
    add_index :users, :login, :unique => true

    create_versioned_table :dynamic_views do |t|
      t.string :type
      t.string :name
      t.string :format
      t.string :handler
      t.text :body
      t.timestamps
    end

    create_versioned_table :pages do |t|
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

    create_table :content_type_groups do |t|
      t.string :name
      t.timestamps
    end
    ContentTypeGroup.create!(:name => "Core")

    create_table :content_types do |t|
      t.string :name
      t.belongs_to :content_type_group
      t.integer :priority, :default => 2
      t.timestamps
    end

    create_table :category_types do |t|
      t.string :name
      t.timestamps
    end
    ContentType.create!(:name => "CategoryType", :group_name => "Categorization")

    create_table :categories do |t|
      t.belongs_to :category_type
      t.belongs_to :parent
      t.string :name
      t.timestamps
    end
    ContentType.create!(:name => "Category", :group_name => "Categorization")

    create_table :connectors do |t|
      t.integer :page_id
      t.integer :page_version
      t.integer :connectable_id
      t.string :connectable_type
      t.integer :connectable_version
      t.string :container
      t.integer :position
      t.timestamps
    end

    create_versioned_table :html_blocks do |t|
      t.string :name
      t.string :content, :limit => 64.kilobytes + 1
    end
    ContentType.create!(:name => "HtmlBlock", :group_name => "Core", :priority => 1)

    create_table :sections do |t|
      t.string :name
      t.string :path
      t.boolean :root, :default => false
      t.boolean :hidden, :default => false
      t.timestamps
    end

    create_table :portlets do |t|
      t.string :type
      t.string :name
      t.boolean :archived, :default => false
      t.boolean :deleted, :default => false
      t.integer :created_by_id, :updated_by_id
      t.timestamps
    end
    create_table :portlet_attributes do |t|
      t.integer :portlet_id
      t.string :name
      t.text :value
    end
    ContentType.create!(:name => "Portlet", :group_name => "Core", :priority => 1)

    create_table :redirects do |t|
      t.string :from_path
      t.string :to_path
      t.timestamps
    end

    create_versioned_table :attachments do |t|
      t.string :file_path
      t.string :file_location
      t.string :file_extension
      t.string :file_type
      t.integer :file_size
      t.timestamps
    end

    create_versioned_table :file_blocks do |t|
      t.string :type
      t.string :name
      t.integer :attachment_id
      t.integer :attachment_version
    end
    ContentType.create!(:name => "FileBlock", :group_name => "Core")
    ContentType.create!(:name => "ImageBlock", :group_name => "Core")

    create_table :group_types do |t|
      t.string :name
      t.boolean :guest, :default => false
      t.boolean :cms_access, :default => false
      t.timestamps
    end
    create_table :groups do |t|
      t.string :name
      t.string :code
      t.integer :group_type_id
      t.timestamps
    end
    create_table :user_group_memberships do |t|
      t.integer :user_id
      t.integer :group_id
    end

    create_table :permissions do |t|
      t.string :name
      t.string :full_name
      t.string :description
      t.string :for_module
      t.timestamps
    end
    create_table :group_permissions do |t|
      t.integer :group_id
      t.integer :permission_id
    end
    create_table :group_type_permissions do |t|
      t.integer :group_type_id
      t.integer :permission_id
    end
    create_table :group_sections do |t|
      t.integer :group_id
      t.integer :section_id
    end

    create_table :sites do |t|
      t.string :name
      t.string :domain
      t.boolean :the_default
      t.timestamps
    end

    create_table :section_nodes do |t|
      t.integer :section_id
      t.string :node_type
      t.integer :node_id
      t.integer :position
      t.timestamps
    end

    create_versioned_table :links do |t|
      t.string :name
      t.string :url
      t.boolean :new_window, :default => false
      t.timestamps
    end

    create_table :tags do |t|
      t.string :name
      t.timestamps
    end
    ContentType.create!(:name => "Tag", :group_name => "Categorization")

    create_table :taggings do |t|
      t.integer :tag_id
      t.integer :taggable_id
      t.string :taggable_type
      t.integer :taggable_version
      t.timestamps
    end

    create_table :email_messages do |t|
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

    create_table :tasks do |t|
      t.integer :assigned_by_id
      t.integer :assigned_to_id
      t.integer :page_id
      t.text :comment
      t.date :due_date
      t.datetime :completed_at
      t.timestamps
    end

    create_table :page_routes do |t|
      t.string :name
      t.string :pattern
      t.belongs_to :page
      t.text :code
      t.timestamps
    end                 
    create_table :page_route_options do |t|
      t.belongs_to :page_route
      t.string :type
      t.string :name
      t.string :value
      t.timestamps
    end
  end

  def self.down
    drop_table :page_route_options
    drop_table :page_routes
    drop_table :tasks
    drop_table :email_messages
    drop_table :taggings
    drop_table :tags
    drop_versioned_table :links
    drop_table :section_nodes
    drop_table :sites
    drop_table :group_sections
    drop_table :group_type_permissions
    drop_table :group_permissions
    drop_table :permissions
    drop_table :user_group_memberships
    drop_table :groups
    drop_table :group_types
    drop_versioned_table :file_blocks
    drop_table :attachments
    drop_table :redirects
    drop_table :portlet_attributes
    drop_table :portlets
    drop_table :sections
    drop_versioned_table :html_blocks
    drop_table :connectors
    drop_table :categories
    drop_table :category_types
    drop_table :content_types
    drop_table :content_type_groups
    drop_versioned_table :pages
    drop_versioned_table :dynamic_views
    drop_table "users"
  end
end
