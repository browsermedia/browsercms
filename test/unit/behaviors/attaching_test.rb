require 'test_helper'

[:default_attachables, :versioned_attachables, :non_attachable_block, :two_attachments, :has_many_attachments, :has_thumbnails].each do |table|
  DatabaseHelpers.ensure_content_table_exists table
end

class NonAttachableBlock < ActiveRecord::Base
  acts_as_content_block :allow_attachments => false
end

class DefaultAttachable < ActiveRecord::Base
  acts_as_content_block
  has_attachment :spreadsheet
end

class TwoAttachments < ActiveRecord::Base
  acts_as_content_block
  has_attachment :doc1
  has_attachment :doc2
end

class FactoryTest < ActiveSupport::TestCase
  test "VersionedAttachable#create via Factory should work " do
    f = build(:versioned_attachable)
    assert_not_nil f
  end
end

module DefaultUrls
  def assert_has_default_url(attachment)
    assert_equal default_url_for(attachment), attachment.url
  end

  def default_url_for(attachment)
    "/attachments/#{attachment.id}/#{attachment.data_file_name}"
  end
end

module Cms
  class AttachableBehaviorTest < ActiveSupport::TestCase

    include DefaultUrls

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
      assert_has_default_url @attachable.spreadsheet

      reset(:attachable)

      assert_equal root_section, @attachable.spreadsheet.section
      assert_equal root_section.id, @attachable.spreadsheet.section_id
      assert_has_default_url @attachable.spreadsheet
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

      assert_has_default_url @attachable.spreadsheet

      assert_not_nil @attachable.spreadsheet, "After attaching a file, the Attachment should exist"

      reset(:attachable)

      assert_not_nil @attachable.spreadsheet, "The attachment should have been saved and reloaded."
      assert_equal root_section, @attachable.spreadsheet.section
      assert_equal root_section.id, @attachable.spreadsheet.section_id
      assert_has_default_url @attachable.spreadsheet

      assert @attachable.spreadsheet.published?
    end

  end

  class DynamicallyLookupStylesTest < ActiveSupport::TestCase

    test "has_assigned_content_type?" do
      c = Cms::Attachment
      refute c.new.has_assigned_content_type?
      refute c.new(:attachable_type => "HasThumbnails").has_assigned_content_type?
      assert c.new(:attachable_type => "HasThumbnails", :attachment_name => "document").has_assigned_content_type?
      assert create(:attachment_document, :attachable_type => "HasThumbnail", :attachment_name => "document").has_assigned_content_type?

    end
    test "A new Cms::Attachment has no styles" do
      attachment = Cms::Attachment.new
      assert_equal({}, Cms::Attachment.dynamically_return_styles.call(attachment.data))
    end

    test "An attachment assigned to an attachable should use its styles" do
      attachment = Cms::Attachment.new(:attachable_type => "HasThumbnail", :attachment_name => "document")
      assert_equal({"thumbnail" => "50x50"}, Cms::Attachment.dynamically_return_styles.call(attachment.data))
    end

    test "styles for thumbnails" do
      block = HasThumbnail.new
      block.attachments << create(:attachment_document, :attachable_type => "HasThumbnail")
      block.save!

      expected_styles = block.document.data.styles
      assert_equal "thumbnail", expected_styles.keys.first
      assert_equal({"thumbnail" => "50x50"}, Cms::Attachment.dynamically_return_styles.call(block.document.data))
    end

    test "styles for versioned" do
      block = create(:versioned_attachable)

      expected_styles = block.document.data.styles
      assert_equal({}, expected_styles)
    end

  end

  class RenderingStylesTest < ActiveSupport::TestCase

    test "url for thumbnail" do
      attachment = create(:thumbnail_attachment)
      assert_equal "/attachments/#{attachment.id}/foo.jpg", attachment.url
      assert_equal "/attachments/#{attachment.id}/foo.jpg?style=thumbnail", attachment.url(:thumbnail)
    end
  end

  class AttachingTest < ActiveSupport::TestCase

    test "Mass Assignment: attachment_id_list" do
      assert_nothing_raised do
        DefaultAttachable.new(:attachment_id_list => "1,2")
      end
    end

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

  class TwoAttachmentsTest < ActiveSupport::TestCase

    def setup
      @content = TwoAttachments.create!(attachments_hash(:name => 'doc1').merge({:publish_on_save => true, :name => "Test"}))
      assert_equal 1, @content.attachments.size
      assert_not_nil @content.doc1, "Has one document"
      assert_nil @content.doc2, "But not the second"
    end

    test "with two attachments, ensure should make sure both are available, even if only one has been uploaded." do
      @content.ensure_attachment_exists

      assert_equal 2, @content.attachments.size
      assert_not_nil @content.doc1
      assert_not_nil @content.doc2
    end

    test "Can build attachments after loading a specific version" do
      draft = @content.as_of_draft_version()

      draft.ensure_attachment_exists

      assert_equal 2, draft.attachments.size
      assert_not_nil draft.doc1
      assert_not_nil draft.doc2
    end
  end

  class SendFileStrategyTest < ActiveSupport::TestCase
    test "send_attachment" do
      expected_path = "/some/path"
      given_an_attachment_with_file_path(expected_path, :style => "original")
      then_controller_should_send_file(expected_path)

      Cms::Attachments::FilesystemStrategy.send_attachment(@attachment, @controller)
    end

    test "send_attachment with style" do
      thumbnail_path = "/thumbnail/path"
      given_an_attachment_with_file_path(thumbnail_path, :style => "thumbnail")
      then_controller_should_send_file(thumbnail_path, :style => "thumbnail")

      Cms::Attachments::FilesystemStrategy.send_attachment(@attachment, @controller)
    end

    private
    def given_an_attachment_with_file_path(expected_path, options={})
      @attachment = stub(:file_name => "NAME", :file_type => "TYPE")
      expect = @attachment.expects(:path).with(options[:style]).returns(expected_path)
      File.expects(:exists?).with(expected_path).returns(true)
    end

    def then_controller_should_send_file(expected_path, options={})
      @controller = mock()
      @controller.expects(:send_file).with(expected_path, {:filename => @attachment.file_name, :type => @attachment.file_type, :disposition => "inline"})
      @controller.expects(:params).returns(options)

    end
  end

  class AttachmentServingStrategyTest < ActiveSupport::TestCase

    class Cms::Attachments::AnotherStrategy
      def send_attachment(attachment, controller)
      end
    end
    include Cms::Attachments::Serving

    def setup
      @attachment = build(:attachment_document)
    end

    test "#send_attachments_with :filesystem" do
      when_attachment_storage_is :filesystem
      assert_equal Cms::Attachments::FilesystemStrategy, send_attachments_with
    end

    test "#send_attachments_with :another" do
      when_attachment_storage_is :another
      assert_equal Cms::Attachments::AnotherStrategy, send_attachments_with
    end

    test "default strategy is :filesystem" do
      then_use_this_strategy_to_send_attachments(Cms::Attachments::FilesystemStrategy)
      send_attachment(@attachment)
    end

    test "#send_attachment from filesystem" do
      when_attachment_storage_is(:filesystem)
      then_use_this_strategy_to_send_attachments(Cms::Attachments::FilesystemStrategy)

      send_attachment(@attachment)
    end

    test "#send_attachment with another strategy" do
      when_attachment_storage_is(:another)
      then_use_this_strategy_to_send_attachments(Cms::Attachments::AnotherStrategy)

      send_attachment(@attachment)
    end

    test "Attachment#path for :filesystem" do
      when_attachment_storage_is :filesystem

      assert_equal "#{Rails.root}/tmp/uploads/#{id_partition}/original/#{@attachment.data_fingerprint}", @attachment.path
    end


    private

    def id_partition
      ""
    end

    def then_use_this_strategy_to_send_attachments(strategy)
      self.expects(:current_user).returns(stub(:able_to_view? => true))
      strategy.expects(:send_attachment).with(@attachment, self)
    end

    def when_attachment_storage_is(value)
      Rails.configuration.cms.attachments.expects(:storage).returns(value)
    end


  end
  class AttachmentConfigurationTest < ActiveSupport::TestCase

    test "#definitions_for" do
      assert_equal({"type" => :single, "index" => 0}, VersionedAttachable.definitions_for(:document))
    end

    test "#config for unassociated attachment returns empty Hash" do
      assert_equal({}, Cms::Attachment.new.config)
    end

    test "#config should return the definitions for a given attachment type" do
      single_attachment = create(:versioned_attachable).attachments.first
      assert_equal :single, single_attachment.config[:type]
    end

    test "#config multiple cardinality" do
      multiple_attachments = create(:has_many_attachments).attachments.first
      assert_equal :multiple, multiple_attachments.config[:type]
    end

    test "Unassociated attachments are linked when the block is saved." do
      attachment = create(:attachment_document, :attachment_name => 'documents', :attachable_type => 'HasManyAttachments')
      assert_nil attachment.attachable_version
      assert_nil attachment.attachable_id

      block = HasManyAttachments.new(:name => "Hello", :publish_on_save => true)
      block.attachment_id_list = "#{attachment.id}"
      assert block.save!

      assert_equal 1, block.as_of_version(1).attachments.size
    end
  end

  class AttachableTest < ActiveSupport::TestCase

    include DefaultUrls

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
          :path => nil,
          :parent => root_section,
          :more_created => true
      }
      expected.merge!(expected_values)


      attachable_count = VersionedAttachable.count

      assert @attachable.save!
      unless expected[:path]
        expected[:path] = default_url_for(@attachable.document)
      end
      assert_incremented attachable_count, VersionedAttachable.count if expected[:more_created]
      assert_equal expected[:parent], @attachable.document.parent
      assert_equal expected[:parent].id, @attachable.document.parent.id
      assert_equal expected[:path], @attachable.document.url

      reset(:attachable)

      assert_equal expected[:parent], @attachable.document.parent
      assert_equal expected[:parent].id, @attachable.document.parent.id
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

    test "adding new attachments will mark the attachable as changed" do
      @attachable.attachments_changed = "true"
      @attachable.valid?
      assert @attachable.changed?
    end

    test "blank attachments_changed" do
      @attachable.attachments_changed = ""
      @attachable.valid?
      refute @attachable.changed?
    end

    test "false attachments_changed" do

      @attachable.attachments_changed = "false"
      @attachable.valid?
      refute @attachable.changed?
    end
    test "Get attachment by name" do
      assert_equal @attachable.attachments[0], @attachable.document
    end

    test "#has_attachment :name add name? method" do
      assert @attachable.document?
    end

    def test_updating_the_attachment_file_name
      @attachable.attachments[0].data_file_path = "/new-path.txt"
      @attachable.save!
      assert_equal "/new-path.txt", @attachable.attachments[0].data_file_path

    end

    test "update the file" do
      @file = mock_file(:original_filename => 'version2.txt')
      @attachable.attachments[0].data = @file
      @attachable.save!

      assert_equal file_contents(@file.path), file_contents(@attachable.attachments[0].path)
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

    test "#multiple_attachments for draft versions" do
      update_attachable

      draft = @attachable.as_of_draft_version
      assert_equal [], draft.multiple_attachments
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

      assert_equal file_contents(@file.path), file_contents(@attachable.as_of_version(1).attachments[0].path), "The contents of version 1 of the file should be returned"
      assert_equal file_contents(file2.path), file_contents(@attachable.as_of_version(2).attachments[0].path)
    end

    test "Deleting an attachment does not increment the version # of the block" do
      # Note: This probably SHOULD NOT work this way, but it does for now.
      # The UI will handle updating versions of blocks
      @attachable.attachments.first.destroy
      @attachable.reload

      assert_equal 1, @attachable.version
    end

    test "delete an attachment should not be found when fetching the draft version of blocks" do
      @attachable.attachments.first.destroy
      update_to_version(@attachable)

      current = @attachable.as_of_draft_version()
      assert_equal 0, current.attachments.size
    end


    test "deleted attachments should be found when looking up historical versions" do
      @attachable.attachments.first.destroy
      update_to_version(@attachable)

      assert_equal 0, @attachable.as_of_version(2).attachments.size
      assert_equal 1, @attachable.as_of_version(1).attachments.size
    end

    test "reverting with multiple attachments doesn't work correctly'" do
      @attachable = create(:has_many_attachments)

      @attachable.attachments.first.destroy
      update_to_version(@attachable, 2)
      @attachable.attachments << create(:has_many_documents, :data_file_name => "new.txt", :attachable_version => 2)
      update_to_version(@attachable, 3)

      assert_equal "new.txt", @attachable.attachments.first.data_file_name

      @attachable.revert_to(1)
      @attachable.reload

      assert_equal 1, @attachable.attachments.size
      assert_equal "new.txt", @attachable.attachments.first.data_file_name, "If this worked properly, it roll back to version 1 of the attachment."

    end
    private

    def update_to_version(attachable, v=2)
      attachable.update_attributes(:name => "v#{v}")
      attachable.publish!
      attachable.reload
      assert_equal v, attachable.version, "Verifying that we have actually force this block to version #{v}"
    end

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
