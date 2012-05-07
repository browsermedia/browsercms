require 'cms/upgrades/v3_5_0'

class UpdateAttachmentData < ActiveRecord::Migration

  def change
    migrate_attachment_for(Cms::ImageBlock)
    migrate_attachment_for(Cms::FileBlock)
    move_attachments_to_new_location
  end

end
