class Browsercms300 < ActiveRecord::Migration
  def self.up
    create_table prefix(:users), :force => true do |t|
      t.column :login, :string, :limit => 40
      t.column :first_name, :string, :limit => 40
      t.column :last_name, :string, :limit => 40
      t.column :email, :string, :limit => 40
      t.column :crypted_password, :string, :limit => 40
      t.column :salt, :string, :limit => 40
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :expires_at, :datetime
      t.column :remember_token, :string, :limit => 40
      t.column :remember_token_expires_at, :datetime
    end
    add_index prefix(:users), :login, :unique => true

    create_content_table :dynamic_views do |t|
      t.string :type
      t.string :name
      t.string :format
      t.string :handler
      t.text :body
      t.timestamps
    end

    create_content_table :pages do |t|
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

    create_table prefix(:content_type_groups) do |t|
      t.string :name
      t.timestamps
    end

    create_table prefix(:content_types) do |t|
      t.string :name
      t.belongs_to :content_type_group
      t.integer :priority, :default => 2
      t.timestamps
    end

    create_table prefix(:category_types) do |t|
      t.string :name
      t.timestamps
    end

    create_table prefix(:categories) do |t|
      t.belongs_to :category_type
      t.belongs_to :parent
      t.string :name
      t.timestamps
    end

    create_table prefix(:connectors) do |t|
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

    create_table prefix(:sections) do |t|
      t.string :name
      t.string :path
      t.boolean :root, :default => false
      t.boolean :hidden, :default => false
      t.timestamps
    end

    create_table prefix(:portlets) do |t|
      t.string :type
      t.string :name
      t.boolean :archived, :default => false
      t.boolean :deleted, :default => false
      t.integer :created_by_id, :updated_by_id
      t.timestamps
    end
    create_table prefix(:portlet_attributes) do |t|
      t.integer :portlet_id
      t.string :name
      t.text :value
    end

    create_table prefix(:redirects) do |t|
      t.string :from_path
      t.string :to_path
      t.timestamps
    end

    create_content_table :attachments do |t|
      t.string :file_path
      t.string :file_location
      t.string :file_extension
      t.string :file_type
      t.integer :file_size
      t.timestamps
    end

    create_content_table :file_blocks do |t|
      t.string :type
      t.string :name
      t.integer :attachment_id
      t.integer :attachment_version
    end

    create_table prefix(:group_types) do |t|
      t.string :name
      t.boolean :guest, :default => false
      t.boolean :cms_access, :default => false
      t.timestamps
    end
    create_table prefix(:groups) do |t|
      t.string :name
      t.string :code
      t.integer :group_type_id
      t.timestamps
    end
    create_table prefix(:user_group_memberships) do |t|
      t.integer :user_id
      t.integer :group_id
    end

    create_table prefix(:permissions) do |t|
      t.string :name
      t.string :full_name
      t.string :description
      t.string :for_module
      t.timestamps
    end
    create_table prefix(:group_permissions) do |t|
      t.integer :group_id
      t.integer :permission_id
    end
    create_table prefix(:group_type_permissions) do |t|
      t.integer :group_type_id
      t.integer :permission_id
    end
    create_table prefix(:group_sections) do |t|
      t.integer :group_id
      t.integer :section_id
    end

    create_table prefix(:sites) do |t|
      t.string :name
      t.string :domain
      t.boolean :the_default
      t.timestamps
    end

    create_table prefix(:section_nodes) do |t|
      t.integer :section_id
      t.string :node_type
      t.integer :node_id
      t.integer :position
      t.timestamps
    end

    create_content_table :links do |t|
      t.string :name
      t.string :url
      t.boolean :new_window, :default => false
      t.timestamps
    end

    create_table prefix(:tags) do |t|
      t.string :name
      t.timestamps
    end

    create_table prefix(:taggings) do |t|
      t.integer :tag_id
      t.integer :taggable_id
      t.string :taggable_type
      t.integer :taggable_version
      t.timestamps
    end

    create_table prefix(:email_messages) do |t|
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

    create_table prefix(:tasks) do |t|
      t.integer :assigned_by_id
      t.integer :assigned_to_id
      t.integer :page_id
      t.text :comment
      t.date :due_date
      t.datetime :completed_at
      t.timestamps
    end

    create_table prefix(:page_routes) do |t|
      t.string :name
      t.string :pattern
      t.belongs_to :page
      t.text :code
      t.timestamps
    end
    create_table prefix(:page_route_options) do |t|
      t.belongs_to :page_route
      t.string :type
      t.string :name
      t.string :value
      t.timestamps
    end
  end

  def self.down
    drop_table prefix(:page_route_options)
    drop_table prefix(:page_routes)
    drop_table prefix(:tasks)
    drop_table prefix(:email_messages)
    drop_table prefix(:taggings)
    drop_table prefix(:tags)
    drop_versioned_table :links
    drop_table prefix(:section_nodes)
    drop_table prefix(:sites)
    drop_table prefix(:group_sections)
    drop_table prefix(:group_type_permissions)
    drop_table prefix(:group_permissions)
    drop_table prefix(:permissions)
    drop_table prefix(:user_group_memberships)
    drop_table prefix(:groups)
    drop_table prefix(:group_types)
    drop_versioned_table :file_blocks
    drop_versioned_table :attachments
    drop_table prefix(:redirects)
    drop_table prefix(:portlet_attributes)
    drop_table prefix(:portlets)
    drop_table prefix(:sections)
    drop_versioned_table :html_blocks
    drop_table prefix(:connectors)
    drop_table prefix(:categories)
    drop_table prefix(:category_types)
    drop_table prefix(:content_types)
    drop_table prefix(:content_type_groups)
    drop_versioned_table :pages
    drop_versioned_table :dynamic_views
    drop_table prefix(:users)
  end
end
