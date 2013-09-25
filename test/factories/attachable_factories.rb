# Factories for testing Attachable Blocks
class VersionedAttachable < ActiveRecord::Base
  acts_as_content_block content_module: false

  # Not sure why this is needed, but tests fail from rake if not here
 #attr_accessible :name
  has_attachment :document
end

class HasManyAttachments < ActiveRecord::Base
  acts_as_content_block content_module: false
  has_many_attachments :documents
end

class HasThumbnail < ActiveRecord::Base
  acts_as_content_block content_module: false
  has_attachment :document, :styles => {:thumbnail => "50x50"}
end

FactoryGirl.define do

  # Duplicates :file_block
  factory :versioned_attachable, :class => VersionedAttachable do |m|
    ignore do
      parent { find_or_create_root_section }
      attachment_file { mock_file }
      attachment_file_path { nil }
    end
    m.sequence(:name) { |n| "VersionedAttachable#{n}" }
    m.after(:build) { |f, evaluator|
      opts = {:data => evaluator.attachment_file, :attachment_name => 'document'}
      opts[:parent] = evaluator.parent if evaluator.parent # Handle :parent=>nil
      opts[:data_file_path] = evaluator.attachment_file_path if evaluator.attachment_file_path
      f.attachments.build(opts)
    }
    m.publish_on_save true
  end

  factory :has_many_attachments, :class => HasManyAttachments do |m|
    ignore do
      parent { find_or_create_root_section }
      attachment_file { mock_file }
      attachment_file_path { nil }
    end
    m.sequence(:name) { |n| "HasManyAttachments#{n}" }
    m.after(:build) { |f, evaluator|
      opts = {:data => evaluator.attachment_file, :attachment_name => 'documents'}
      opts[:parent] = evaluator.parent if evaluator.parent
      opts[:data_file_path] = evaluator.attachment_file_path if evaluator.attachment_file_path
      f.attachments.build(opts)
    }
    m.publish_on_save true
  end

  factory :has_many_documents, :class => Cms::Attachment do |m|
      m.attachment_name "documents"
      m.attachable_type "HasManyAttachments"
      m.data { mock_file }
      m.parent { find_or_create_root_section }
      m.attachable_version 1
      m.publish_on_save true
  end

  factory :attachment_document, :class => Cms::Attachment do |m|
    m.attachment_name "document"
    m.attachable_type "VersionedAttachable"
    m.data { mock_file }
    m.parent { find_or_create_root_section }
    m.publish_on_save true
  end

  factory :thumbnail_attachment, :class => Cms::Attachment do |m|
      m.attachment_name "document"
      m.attachable_type "HasThumbnail"
      m.data { mock_file }
      m.parent { find_or_create_root_section }
      m.publish_on_save true
  end

  factory :catalog_attachment, :class => Cms::Attachment do |m|
    m.attachment_name "photos"
    m.attachable_type "Dummy::Catalog"
    m.data { mock_text_file }
    m.parent { find_or_create_root_section }
    m.publish_on_save true
  end

end
