require 'cms/upgrades/v3_5_0'
require 'fileutils'

class MigrateFiles < ActiveRecord::Migration
  include Cms::Upgrades::V3_5_0::FileStorageUpdates

  def change
    move_attachments_to_new_location
  end
end
