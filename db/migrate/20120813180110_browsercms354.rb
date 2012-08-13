class Browsercms354 < ActiveRecord::Migration
  def up
    # Attachments should not be overly specific, since it prevents joins from working.
    ["Cms::ImageBlock", "Cms::FileBlock"].each do |old_type|
      Cms::Attachment.unscoped.update_all({:attachable_type => "Cms::AbstractFileBlock"}, {:attachable_type => old_type})
    end
  end
end

