class UpdateAttachmentData < ActiveRecord::Migration
  def change
    update_attachment(Cms::ImageBlock)
    update_attachment(Cms::FileBlock)
  end

  private

  def update_attachment(klass)
    # Update deleted attachments too, for consistency
    klass.unscoped.find_each do |block|
      Cms::Attachment.unscoped.update_all({:attachable_id => block.id, :attachable_version => block.version, :attachable_type => klass.name, :attachment_name => "file", :cardinality => 'single'},
                                          {:id => block.id})
    end
  end
end
