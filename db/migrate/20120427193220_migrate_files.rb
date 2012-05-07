require 'cms/upgrades/v3_5_0'
require 'fileutils'

class MigrateFiles < ActiveRecord::Migration
  include Cms::Upgrades::V3_5_0::FileStorageUpdates

  def up

    # Move attachments
    Cms::Attachment.unscoped.where("attachable_type is NOT NULL").each do |attachment|
      old_location = File.join(Cms::Attachment.configuration.attachments_root, attachment.file_location)
      new_file_location, new_dir = new_file_location(attachment)
      new_location = File.join(Cms::Attachment.configuration.attachments_root, new_file_location)
      new_dir_path = File.join(Cms::Attachment.configuration.attachments_root, new_dir)

      FileUtils.mkdir_p(new_dir_path, :verbose => true)
      FileUtils.cp(old_location, new_location, :verbose => true)

      new_fingerprint = attachment.file_location.split("/").last
      Cms::Attachment.unscoped.update_all({:data_fingerprint => new_fingerprint}, :id => attachment.id)
    end

    # Move Attachment versions
    Cms::Attachment::Version.unscoped.where("attachable_type is NOT NULL").each do |attachment|
      old_location = File.join(Cms::Attachment.configuration.attachments_root, attachment.file_location)
      new_file_location, new_dir = new_file_location(attachment)
      new_location = File.join(Cms::Attachment.configuration.attachments_root, new_file_location)
      new_dir_path = File.join(Cms::Attachment.configuration.attachments_root, new_dir)

      FileUtils.mkdir_p(new_dir_path, :verbose => true)
      FileUtils.cp(old_location, new_location, :verbose => true)

      new_fingerprint = attachment.file_location.split("/").last
      Cms::Attachment::Version.unscoped.update_all({:data_fingerprint => new_fingerprint}, :id => attachment.id)
    end
  end

  def down
  end
end
