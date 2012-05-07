class UpdateAttachmentData < ActiveRecord::Migration
  def change
    update_attachment(Cms::ImageBlock)
    update_attachment(Cms::FileBlock)
    update_versions_table
  end

  private

  def update_attachment(klass)
    # Update deleted attachments too, for consistency
    klass.unscoped.find_each do |block|
      Cms::Attachment.unscoped.update_all({:attachable_id => block.id,
                                           :attachable_version => block.version,
                                           :attachable_type => klass.name,
                                           :attachment_name => "file",
                                           :cardinality => 'single'},
                                          {:id => block.attachment_id})
    end


  end

  def update_versions_table
    found =  Cms::FileBlock::Version.find_by_sql("SELECT original_record_id, attachment_id, version from file_block_versions")
    found.each do |version_record|
      #original_type = Cms::AbstractFileBlock.where(:id => version_record.original_record_id).pluck(:type).first
      Cms::Attachment::Version.unscoped.update_all({:attachable_id => version_record.original_record_id,
                                                    :attachable_version => version_record.version,
                                                    :attachable_type => "Cms::AbstractFileBlock",
                                                    :attachment_name => "file",
                                                    :cardinality => 'single'},
                                                   {:original_record_id => version_record.attachment_id})
    end
  end
end
