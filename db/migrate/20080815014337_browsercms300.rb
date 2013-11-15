class Browsercms300 < ActiveRecord::Migration
  def change
    create_table :cms_users, :force => true do |t|
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
      t.column :reset_token, :string
    end
    add_index :cms_users, :login, :unique => true

    create_content_table :cms_dynamic_views do |t|
      t.string :type
      t.string :name
      t.string :format
      t.string :handler
      t.text :body
      t.timestamps
    end

    create_content_table :cms_pages do |t|
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
    add_column :cms_pages, :latest_version, :integer

    create_table :cms_content_type_groups do |t|
      t.string :name
      t.timestamps
    end

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

    create_table :cms_categories do |t|
      t.belongs_to :category_type
      t.belongs_to :parent
      t.string :name
      t.timestamps
    end

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

    create_content_table :cms_html_blocks do |t|
      t.text :content, :limit => 64.kilobytes + 1
    end

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

    create_table :cms_redirects do |t|
      t.string :from_path
      t.string :to_path
      t.timestamps
    end

    create_content_table :cms_attachments, name: false do |t|
      t.string :data_file_name
      t.string :data_file_path
      t.string :file_location
      t.string :data_content_type
      t.integer :data_file_size
      t.string :data_fingerprint
      t.string :attachable_type
      t.string :attachment_name
      t.integer :attachable_id
      t.integer :attachable_version
      t.string :cardinality
    end

    create_content_table :cms_file_blocks do |t|
      t.string :type
      t.string :name
      t.integer :attachment_id
      t.integer :attachment_version
    end

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
      t.string :node_type
      t.integer :node_id
      t.integer :position
      t.string :ancestry
      t.timestamps
    end

    create_content_table :cms_links do |t|
      t.string :name
      t.string :url
      t.boolean :new_window, :default => false
      t.timestamps
    end
    add_column :cms_links, :latest_version, :integer


    create_table :cms_tags do |t|
      t.string :name
      t.timestamps
    end

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

    INDEXES.each do |index|
      table_name, column = *index
      add_index cms_(table_name), column
    end
  end

  # Add some very commonly used indexes to improve the site performance as the # of pages/content grows (i.e. several thousand pages)
  INDEXES = [
      [:pages, :deleted],
      [:pages, :path],
      [:pages, :version],
      [:page_versions, :original_record_id],
      [:groups, :code],
      [:groups, :group_type_id],
      [:group_types, :cms_access],
      [:group_sections, :section_id],
      [:group_sections, :group_id],
      [:users, :expires_at],
      [:user_group_memberships, :group_id],
      [:user_group_memberships, :user_id],
      [:group_permissions, :group_id],
      [:group_permissions, :permission_id],
      [:group_permissions, [:group_id, :permission_id]],
      [:section_nodes, :node_type],
      [:section_nodes, :ancestry],
      [:connectors, :page_id],
      [:connectors, :page_version],
      [:html_blocks, :deleted],
      [:html_block_versions, :original_record_id],
      [:html_block_versions, :version],
      [:portlet_attributes, :portlet_id],
      [:portlets, :name],
      [:sections, :path],
      [:redirects, :from_path],
      [:connectors, :connectable_version],
      [:connectors, :connectable_type],
      [:content_types, :content_type_group_id],
      [:content_types, :name],
      [:file_block_versions, :original_record_id],
      [:file_block_versions, :version],
      [:file_blocks, :deleted],
      [:file_blocks, :type],
      [:attachment_versions, :original_record_id],
      [:tasks, :page_id],
      [:tasks, :completed_at],
      [:tasks, :assigned_to_id],
  ]
end
