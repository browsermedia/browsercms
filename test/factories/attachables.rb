# Factories for testing Attachable Blocks
class VersionedAttachable < ActiveRecord::Base
  acts_as_content_block
  has_attachment :document
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
    m.after_build { |f, evaluator|
      opts =  {:data => evaluator.attachment_file, :attachment_name => 'document' }
      opts[:parent] = evaluator.parent if evaluator.parent  # Handle :parent=>nil
      opts[:data_file_path] = evaluator.attachment_file_path if evaluator.attachment_file_path
      f.attachments.build(opts)
    }
    m.publish_on_save true
  end
end
