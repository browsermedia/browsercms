require 'test_helper'

[:default_attachables, :versioned_attachables, :non_attachable_block].each do |t|
  DatabaseHelpers.ensure_content_table_exists t
end

class NonAttachableBlock < ActiveRecord::Base
  acts_as_content_block :allow_attachments => false
end

class DefaultAttachable < ActiveRecord::Base
  acts_as_content_block
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
                                              :attachments_attributes => new_attachment(),
                                              :publish_on_save => true)
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

      @attachable = DefaultAttachable.new(:name => "File Name", :attachments_attributes => new_attachment())
      attachable_count = DefaultAttachable.count

      @attachable.save!

      assert_incremented attachable_count, DefaultAttachable.count
      assert_equal root_section, @attachable.spreadsheet.parent
      assert_equal root_section.id, @attachable.spreadsheet.parent.id
      assert_equal "/attachments/DefaultAttachable_foo.jpg", @attachable.spreadsheet.url

      reset(:attachable)

      assert_equal root_section, @attachable.spreadsheet.section
      assert_equal root_section.id, @attachable.spreadsheet.section_id
      assert_equal "/attachments/DefaultAttachable_foo.jpg", @attachable.spreadsheet.url
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

      @attachable.attachments_attributes = new_attachment()
      assert_equal true, @attachable.save!
      assert_equal true, @attachable.publish!

      assert_equal "/attachments/DefaultAttachable_foo.jpg", @attachable.spreadsheet.url

      assert_not_nil @attachable.spreadsheet, "After attaching a file, the Attachment should exist"

      reset(:attachable)

      assert_not_nil @attachable.spreadsheet, "The attachment should have been saved and reloaded."
      assert_equal root_section, @attachable.spreadsheet.section
      assert_equal root_section.id, @attachable.spreadsheet.section_id
      assert_equal "/attachments/DefaultAttachable_foo.jpg", @attachable.spreadsheet.url
      assert @attachable.spreadsheet.published?
    end

  end

  class AttachingTest < ActiveSupport::TestCase

    test "Content blocks should be able to have attachments by default" do
      assert DefaultAttachable.respond_to? :has_attachment, "Allows blocks to define a single named attachment"
    end

    test "Content blocks should be able to have multiple attachments by default" do
      assert DefaultAttachable.respond_to? :has_many_attachments, "Allows blocks to define multiple attachments"
    end

    test "Blocks can be configured to not be allowed to have attachments." do
      refute NonAttachableBlock.respond_to? :has_attachment
      refute NonAttachableBlock.respond_to? :has_many_attachments
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


    test "#attachment_names returns a list of each attachment defined for a content type" do
      assert_equal ["document"], VersionedAttachable.new.attachment_names
    end

    test "#ensure_attachments_exist sets up a default attachment for each one" do
      attachable = VersionedAttachable.new
      attachable.ensure_attachment_exists

      assert_equal 1, attachable.attachments.size
      assert_equal "document", attachable.attachments.first.attachment_name
    end

    test "Calling #ensure doesn't create duplicates" do
      attachable = VersionedAttachable.new
      attachable.ensure_attachment_exists
      attachable.ensure_attachment_exists

      assert_equal 1, attachable.attachments.size
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

    protected
    def assert_was_saved_properly(expected_values)
      expected = {
          :path => "/attachments/VersionedAttachable_foo.jpg",
          :parent => root_section,
          :more_created => true
      }
      expected.merge!(expected_values)

      attachable_count = VersionedAttachable.count

      assert @attachable.save!

      assert_incremented attachable_count, VersionedAttachable.count if expected[:more_created]
      assert_equal expected[:parent], @attachable.document.parent
      assert_equal expected[:parent].id, @attachable.document.parent.id
      assert_equal expected[:path], @attachable.document.data_file_path
      assert_equal expected[:path], @attachable.document.url

      reset(:attachable)

      assert_equal expected[:parent], @attachable.document.parent
      assert_equal expected[:parent].id, @attachable.document.parent.id
      assert_equal expected[:path], @attachable.document.data_file_path
      assert_equal expected[:path], @attachable.document.url
    end

  end


  class UpdatingAttactableTest < ActiveSupport::TestCase

    def setup
      @attachable = create(:versioned_attachable)
    end

    test "updating an attachment will mark the attachable record as changed" do
      @attachable.document.attachment_name = "new.pdf"
      @attachable.valid?

      assert @attachable.changed?
    end

    test "Get attachment by name" do
      assert_equal @attachable.attachments[0], @attachable.document
    end

    test "#has_attachment :name add name? method" do
      assert @attachable.document?
    end

    def test_updating_the_attachment_file_name
      @attachable.attachments[0].data_file_path = "/new-path.txt"
      update_attachable
      assert_equal "/new-path.txt", @attachable.attachments[0].data_file_path

    end

    test "update the file" do
      @file = mock_file(:original_filename => 'version2.txt')
      @attachable.attachments[0].data = @file
      update_attachable

      assert_equal file_contents(@file.path), file_contents(@attachable.attachments[0].full_file_location)
    end

    private

    def update_attachable
      @attachable.name = "Force an update"
      @attachable.publish_on_save = true
      @attachable.save!
      reset(:attachable)
    end
  end

  class VersionedAttachableTest < ActiveSupport::TestCase
    def setup
      @file = mock_file
      @section = create(:section, :name => "attachables", :parent => root_section)
      @attachable = create(:versioned_attachable, :parent => @section, :attachment_file => @file, :attachment_file_path => "version1.txt")
      reset(:attachable)
    end

    test "1 attachment version" do
      log_table Cms::Attachment::Version
      assert_equal 1, Cms::Attachment::Version.count
    end

    test "#respond_to after_build_new_version callback" do
      assert @attachable.respond_to? :after_build_new_version
    end

    test "#respond_to after_as_of_version" do
      assert @attachable.respond_to? :after_as_of_version
    end

    test "#attachable_version matches block version" do
      assert_equal @attachable.version, @attachable.attachments[0].attachable_version
    end

    test "Total # of attachments shouldn't change'" do
      assert_no_difference lambda { Cms::Attachment.count } do
        update_attachable
      end
    end

    test "# of attachment versions shouldn't change'" do
      assert_difference 'Cms::Attachment::Version.count', 1 do
        update_attachable
      end
    end

    test "Attachments should be the same" do
      update_attachable
      assert_equal @attachable.as_of_version(1).attachments[0], @attachable.as_of_version(2).attachments[0]
    end


    test "updating the attachment path should create a new version" do
      assert_difference 'Cms::Attachment::Version.count', 1 do
        update_attachable_to_version2("/version2.txt")
      end
    end

    test "updating attachment shouldn't create a new attachment'" do
      assert_no_difference 'Cms::Attachment.count' do
        update_attachable_to_version2("/version2.txt")
      end
    end

    test "updating the file should create a new version" do
      assert_difference 'Cms::Attachment::Version.count', 1 do
        update_file_for_attachable
      end
    end

    test "updating the file shouldn't create a new attachment'" do
      assert_no_difference 'Cms::Attachment.count' do
        update_file_for_attachable
      end
    end

    test "Keep older versions of files" do
      file2 = update_file_for_attachable

      assert_equal file_contents(@file.path), file_contents(@attachable.as_of_version(1).attachments[0].full_file_location), "The contents of version 1 of the file should be returned"
      assert_equal file_contents(file2.path), file_contents(@attachable.as_of_version(2).attachments[0].full_file_location)
    end


    private
    def update_attachable_to_version2(new_path)
      @attachable.attachments[0].data_file_path = new_path
      @attachable.name = "Force Update"
      @attachable.publish_on_save = true
      @attachable.save!
      reset(:attachable)
    end


    def update_file_for_attachable()
      new_file = mock_file(:original_filename => "version2.txt")
      @attachable.attachments[0].data = new_file
      @attachable.name = "Force Update"
      @attachable.publish_on_save = true
      @attachable.save!
      new_file
    end

    def update_attachable
      @attachable.update_attributes(:name => "Foo v2")
    end


  end


end
