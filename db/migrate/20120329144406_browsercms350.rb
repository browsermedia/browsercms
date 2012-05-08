require 'cms/upgrades/v3_5_0'

class Browsercms350 < ActiveRecord::Migration
  def change
    migrate_attachments_table
    migrate_attachment_for(Cms::ImageBlock)
    migrate_attachment_for(Cms::FileBlock)
    migrate_attachment_files_to_new_location

  end


  private

  def migrate_attachments_table
    rename_table :attachments, :cms_attachments if table_exists?(:attachments)
    rename_table :attachment_versions, :cms_attachment_versions if table_exists?(:attachment_versions)

    rename_content_column :cms_attachments, :file_path, :data_file_path
    rename_content_column :cms_attachments, :file_size, :data_file_size
    rename_content_column :cms_attachments, :file_type, :data_content_type
    rename_content_column :cms_attachments, :name, :data_file_name
    remove_content_column :cms_attachments, :file_extension

    add_content_column :cms_attachments, :data_fingerprint, :string
    add_content_column :cms_attachments, :attachable_type, :string
    add_content_column :cms_attachments, :attachment_name, :string
    add_content_column :cms_attachments, :attachable_id, :integer
    add_content_column :cms_attachments, :attachable_version, :integer
    add_content_column :cms_attachments, :cardinality, :string
  end
end
