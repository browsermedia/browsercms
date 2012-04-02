require 'test_helper'

ActiveRecord::Base.connection.instance_eval do
  drop_table(:default_attachables) rescue nil
  drop_table(:default_attachable_versions) rescue nil
  create_content_table(:default_attachables, :prefix => false) do |t|
    t.string :name
    t.timestamps
  end

  drop_table(:versioned_attachables) rescue nil
  drop_table(:versioned_attachable_versions) rescue nil
  create_content_table(:versioned_attachables, :prefix => false) do |t|
    t.string :name
    t.timestamps
  end
end

class DefaultAttachable < ActiveRecord::Base
  acts_as_content_block :has_attachments => true
  has_attachment :spreadsheet
end

class FactoryTest < ActiveSupport::TestCase
  test "VersionedAttachable#create via Factory should work " do
    f = build(:versioned_attachable)
    assert_not_nil f
  end
end

module Cms
  class AttachableBehaviorTest < ActiveSupport::TestCase

    def setup
      @file = mock_file
      @attachable = DefaultAttachable.create!(:name => "File Name",
                                              :attachments_attributes => attachment(),
                                              :publish_on_save => true)
    end

    # Shorthand to reduce duplication in tests
    def attachment(file=@file, name="spreadsheet")
      {"0" => {
          :data => file,
          :section_id => root_section,
          :attachment_name => name}}
    end

    test "Create a block with an attached file" do
      assert_equal root_section, @attachable.spreadsheet.parent
    end

    test "Loads attachment" do
      @attachable = DefaultAttachable.find(@attachable.id)

      assert_not_nil @attachable.spreadsheet, "Should have an attachment"
      assert_equal root_section, @attachable.spreadsheet.parent
    end

    def test_create_with_attachment_file

      @attachable = DefaultAttachable.new(:name => "File Name", :attachments_attributes => attachment())
      attachable_count = DefaultAttachable.count

      @attachable.save!

      assert_incremented attachable_count, DefaultAttachable.count
      assert_equal root_section, @attachable.spreadsheet.parent
      assert_equal root_section.id, @attachable.spreadsheet.parent.id
      assert_equal "/attachments/DefaultAttachable_foo.jpg?style=original", @attachable.spreadsheet.url

      reset(:attachable)

      assert_equal root_section, @attachable.spreadsheet.section
      assert_equal root_section.id, @attachable.spreadsheet.section_id
      assert_equal "/attachments/DefaultAttachable_foo.jpg?style=original", @attachable.spreadsheet.url
    end

    test "Publishing block publishes attachment" do
      @attachable.publish!
      assert @attachable.spreadsheet.published?
    end

    def test_create_without_attachment_and_then_add_attachment_on_edit
      @attachable = DefaultAttachable.new(:name => "File Name", :publish_on_save => true)

      assert_difference 'DefaultAttachable.count' do
        assert_valid @attachable
        @attachable.save!
      end

      assert_nil @attachable.spreadsheet, "There should be no attachment saved."

      reset(:attachable)

      @attachable.attachments_attributes = attachment()
      assert_equal true, @attachable.save!
      assert_equal true, @attachable.publish!

      assert_equal "/attachments/DefaultAttachable_foo.jpg?style=original", @attachable.spreadsheet.url

      assert_not_nil @attachable.spreadsheet, "After attaching a file, the Attachment should exist"

      reset(:attachable)

      assert_not_nil @attachable.spreadsheet, "The attachment should have been saved and reloaded."
      assert_equal root_section, @attachable.spreadsheet.section
      assert_equal root_section.id, @attachable.spreadsheet.section_id
      assert_equal "/attachments/DefaultAttachable_foo.jpg?style=original", @attachable.spreadsheet.url
      assert @attachable.spreadsheet.published?
    end

  end

  class AttachingTest < ActiveSupport::TestCase

    test "Blocks should all respond to has_attachments" do
      assert Cms::HtmlBlock.respond_to? :has_attachments
    end

    test "#has_attachments shouldn't be called unless configured'" do
      refute Cms::HtmlBlock.respond_to? :has_attachment
    end

    def test_file_path_sanitization
      {
          "Draft #1.txt" => "Draft_1.txt",
          "Copy of 100% of Paul's Time(1).txt" => "Copy_of_100_of_Pauls_Time-1-.txt"
      }.each do |example, expected|
        assert_equal expected, Attachment.sanitize_file_path(example)
      end
    end

  end

  class AttachableTest < ActiveSupport::TestCase

    def setup
      #file is a mock of the object that Rails wraps file uploads in
      @file = mock_file(:original_filename => "sample_upload.txt")

      @section = create(:section, :name => "attachables", :parent => root_section)
    end

    test "#attachments" do
      doc = build :versioned_attachable
      assert_not_nil doc.attachments
      assert_equal 1, doc.attachments.size
    end

    test "#create with specified Section and Path" do
      @attachable = build(:versioned_attachable, :parent => @section, :attachment_file_path => "/test.jpg")
      assert_was_saved_properly({:path => '/test.jpg', :parent => @section})
    end

    test "#create with file but no section" do
      @attachable = build(:versioned_attachable, :parent => nil)
      assert_was_saved_properly({:parent => root_section})
    end

    test "Should correct non-URL friendly characters from file paths" do
      @attachable = build(:versioned_attachable, :attachment_file_path => "/Broken? Yes & No!.txt")
      assert_was_saved_properly({:path => "/Broken_Yes_-_No.txt"})
    end

    test "Should prepend / to paths that are missing them." do
      @attachable = build(:versioned_attachable, :attachment_file_path => "missing-forward-slash.txt")
      assert_was_saved_properly({:path => "/missing-forward-slash.txt"})
    end

    def test_updating_the_attachment_file_name
      @attachable = create(:versioned_attachable)
      #@attachable = VersionedAttachable.create!(:name => "Foo",
      #                                          :attachment_section_id => @section.id,
      #                                          :attachment_file => @file,
      #                                          :attachment_file_path => "test.jpg")

      reset(:attachable)

      @attachable.document.data_file_path = "/test2.jpg"
      @attachable.name = "Updated"

      attachment_version = @attachable.document.version
      attachment_version_count = Cms::Attachment::Version.count
      assert_was_saved_properly({:path => "/test2.jpg", :more_created => false})
      assert_incremented attachment_version, @attachable.document.version
      assert_incremented attachment_version_count, Cms::Attachment::Version.count

      #attachment_count = Cms::Attachment.count
      #attachment_version = @attachable.attachment_version
      #attachment_version_count = Cms::Attachment::Version.count
      #
      #assert @attachable.update_attributes(:attachment_file_path => "test2.jpg", :publish_on_save => true)
      #
      #assert_equal attachment_count, Cms::Attachment.count
      #
      #assert_incremented attachment_version, @attachable.attachment_version
      #assert_incremented attachment_version_count, Cms::Attachment::Version.count
      #assert_equal "/test2.jpg", @attachable.attachment_file_path

      #reset(:attachable)
      #
      #assert_equal attachment_count, Cms::Attachment.count
      #assert_incremented attachment_version, @attachable.attachment_version
      #assert_incremented attachment_version_count, Cms::Attachment::Version.count
      #assert_equal "/test2.jpg", @attachable.attachment_file_path
    end

    def test_updating_the_attachment_file
      @attachable = create(:versioned_attachable)

      #@attachable = VersionedAttachable.create!(:name => "Foo",
      #                                          :attachment_section_id => @section.id,
      #                                          :attachment_file => @file,
      #                                          :attachment_file_path => "test.jpg")

      reset(:attachable)

      @file2 = mock_file(:original_filename => "second_upload.txt")

      attachment_count = Cms::Attachment.count
      attachment_version = @attachable.document.version
      attachment_version_count = Cms::Attachment::Version.count

      @attachable.document.data = @file2
      @attachable.save!
      #assert @attachable.update_attributes(:attachment_file => @file2)

      assert_equal attachment_count, Cms::Attachment.count
      assert_equal attachment_version, @attachable.reload.document.version
      assert_incremented attachment_version_count, Cms::Attachment::Version.count
      @file.rewind
      assert_equal @file.read, open(@attachable.document.full_file_location) { |f| f.read }

      reset(:attachable)
      @file.rewind
      @file2.rewind

      assert_equal @file.read, open(@attachable.document.as_of_version(1).full_file_location) { |f| f.read }
      assert_equal @file2.read, open(@attachable.document.as_of_version(2).full_file_location) { |f| f.read }

    end

    protected
    def assert_was_saved_properly(expected_values)
      expected = {
          :path => "/attachments/VersionedAttachable_foo.jpg",
          :parent => root_section,
          :more_created => true
      }
      expected.merge!(expected_values)

      # For reasons I'm not 100% sure of, even when data_file_path is set, .url still ALWAYs returns this.
      expected_paperclip_url = "/attachments/VersionedAttachable_foo.jpg?style=original"

      attachable_count = VersionedAttachable.count

      assert @attachable.save!


      assert_incremented attachable_count, VersionedAttachable.count if expected[:more_created]
      assert_equal expected[:parent], @attachable.document.parent
      assert_equal expected[:parent].id, @attachable.document.parent.id
      assert_equal expected[:path], @attachable.document.data_file_path
      assert_equal expected_paperclip_url, @attachable.document.url

      reset(:attachable)

      assert_equal expected[:parent], @attachable.document.parent
      assert_equal expected[:parent].id, @attachable.document.parent.id
      assert_equal expected[:path], @attachable.document.data_file_path
      assert_equal expected_paperclip_url, @attachable.document.url
    end

  end

  class VersionedAttachableTest < ActiveSupport::TestCase
    def setup
      #file is a mock of the object that Rails wraps file uploads in
      @file = mock_file

      @section = create(:section, :name => "attachables", :parent => root_section)

      @attachable = VersionedAttachable.create!(:name => "Foo v1",
                                                :attachment_section_id => @section.id,
                                                :attachment_file => @file,
                                                :attachment_file_path => "test.jpg")
      reset(:attachable)
    end

    def test_updating_the_versioned_attachable
      attachment_count = Cms::Attachment.count
      attachment_version = @attachable.attachment_version
      attachment_version_count = Cms::Attachment::Version.count

      assert @attachable.update_attributes(:name => "Foo v2")

      assert_equal attachment_count, Cms::Attachment.count
      assert_equal attachment_version, @attachable.attachment_version
      assert_equal attachment_version_count, Cms::Attachment::Version.count
      assert_equal "Foo v2", @attachable.name
      assert_equal @attachable.as_of_version(1).attachment, @attachable.as_of_version(2).attachment
    end

    def test_updating_the_versioned_attachable_attachment_file_path
      attachable_count = VersionedAttachable.count
      attachment_count = Cms::Attachment.count
      attachment_version = @attachable.attachment_version
      attachment_version_count = Cms::Attachment::Version.count

      assert @attachable.update_attributes(:attachment_file_path => "test2.jpg")

      assert_equal attachable_count, VersionedAttachable.count
      assert_equal attachment_count, Cms::Attachment.count
      assert_incremented attachment_version, @attachable.attachment_version
      assert_incremented attachment_version_count, Cms::Attachment::Version.count
      assert_equal "/test2.jpg", @attachable.attachment_file_path

      assert_equal @attachable.as_of_version(1).attachment, @attachable.as_of_version(2).attachment
      assert_not_equal @attachable.as_of_version(1).attachment_version, @attachable.as_of_version(2).attachment_version
      assert_equal "/test.jpg", @attachable.as_of_version(1).attachment_file_path
      assert_equal "/test2.jpg", @attachable.as_of_version(2).attachment_file_path
    end

    def test_updating_the_versioned_attachable_attachment_file
      @file2 = mock_file(:original_filename => "second_upload.txt")

      attachable_count = VersionedAttachable.count
      attachment_count = Cms::Attachment.count
      attachment_version = @attachable.attachment_version
      attachment_version_count = Cms::Attachment::Version.count

      assert @attachable.update_attributes(:attachment_file => @file2)

      assert_equal attachable_count, VersionedAttachable.count
      assert_equal attachment_count, Cms::Attachment.count
      assert_incremented attachment_version, @attachable.attachment_version
      assert_incremented attachment_version_count, Cms::Attachment::Version.count

      @file2.rewind
      assert_equal @file2.read, open(@attachable.attachment.full_file_location) { |f| f.read }

      @file.rewind
      assert_equal @file.read, open(@attachable.attachment.as_of_version(1).full_file_location) { |f| f.read }

      @file2.rewind
      assert_equal @file2.read, open(@attachable.attachment.as_of_version(2).full_file_location) { |f| f.read }
    end

  end
end
