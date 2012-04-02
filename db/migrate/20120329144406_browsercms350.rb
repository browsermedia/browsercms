class Browsercms350 < ActiveRecord::Migration
  def change
    add_content_column :cms_attachments, :data_file_name, :string
    add_content_column :cms_attachments, :data_content_type, :string
    add_content_column :cms_attachments, :data_file_size, :integer
    add_content_column :cms_attachments, :data_file_path, :string
    add_content_column :cms_attachments, :data_fingerprint, :string
    add_content_column :cms_attachments, :attachable_type, :string
    add_content_column :cms_attachments, :attachment_name, :string
    add_content_column :cms_attachments, :attachable_id, :integer
    add_content_column :cms_attachments, :cardinality, :string
  end
end
