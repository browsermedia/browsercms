require 'test_helper'


class NewFileTest < ActiveSupport::TestCase

  def setup
    @file = Cms::FileBlock.new
  end

  test "#valid? requires attached file" do
    refute @file.valid?
    assert_equal ["You must upload a file"], @file.errors.get(:attachment)
  end

  test "#valid? requires Name" do
    refute @file.valid?
    assert_equal ["can't be blank"], @file.errors.get(:name)
  end

  test "New FileBlock should have 1 blank attachment" do
    @file.ensure_attachment_exists
    assert_equal 1, @file.attachments.size
  end

  test ":file_block Factory defines a default attachment" do
    f = create(:file_block)
    assert_not_nil f.file
    assert_equal Cms::Attachment, f.file.class
  end
end

module Cms
  class SearchFileBlockTest < ActiveSupport::TestCase

    def setup
      @red = create(:file_block, name: 'red')
      @another_section = create(:section, name: 'another-section')
      @blue = create(:file_block, name: 'blue', parent: @another_section)
      @purple = create(:file_block, name: 'red blue', parent: @another_section)
    end

    test "#search with section_id" do
      results = Cms::FileBlock.search(term: 'red').paginate(page: 1).with_parent_id(@red.parent.id)
      assert_equal [@red], results.to_a
    end

    test "#search with all sections" do
      results = Cms::FileBlock.search(term: 'red').paginate(page: 1).with_parent_id('all')
      assert_equal [@red, @purple], results.to_a
    end
  end
  class FileBlockTest < ActiveSupport::TestCase
    def setup
      @file_block = build(:file_block)
    end
    test "file_size" do
      assert_not_nil build(:file_block).file_size
      assert_not_nil build(:image_block).file_size
      assert_not_nil build(:page).file_size
    end
    def test_table_name
      assert_equal "cms_file_blocks", Cms::FileBlock.table_name
    end

    test "Saving should also save attachment." do
      @file_block.save!
      assert_not_nil @file_block.file

      found = Cms::FileBlock.find(@file_block)
      assert_not_nil found.file
    end

    test "New attachments default to be assigned to root section" do
      @file_block.save!
      assert_equal Section.root.first, @file_block.parent
    end

    test "#path" do
      @file_block.save!
      assert_equal @file_block.file.data_file_path, @file_block.path
    end

    test "#parent= during create()" do
      other_section = create(:section)
      file = create(:file_block, :parent => other_section)
      assert_equal other_section, file.parent
    end


    test "Creating an archived block should mark the attachment as archived" do
      file = create(:file_block, :archived => true)
      assert_equal true, file.archived?
      assert_equal true, file.file.archived?
    end

    test "create via nested assignment" do
      fb = FileBlock.new(attachments_hash(:path => '/new-path.txt'))
      assert_equal 1, fb.attachments.size
      assert_equal "/new-path.txt", fb.attachments[0].data_file_path
    end

    test "don't create without a file data using nested attributes" do
      fb = FileBlock.new(:name => "Any Name", :attachments_attributes => {"0" => {:data_file_path => "/new-path.txt", :attachment_name => "file"}})
      refute fb.valid?
    end

    test "by_section" do
      target_section = create(:public_section)
      fb = create(:file_block, :parent => target_section)

      assert_equal [fb], FileBlock.by_section(target_section).to_a
    end
  end

  class UpdatingFileBlockTest < ActiveSupport::TestCase
    def setup
      @file_block = create(:file_block)
    end


    test "By default, attachment URL should be the data_file_path" do
      @file_block = create(:file_block, :attachment_file_path => "/test.txt")

      assert_equal @file_block.file.data_file_path, @file_block.file.url
      assert_equal "/test.txt", @file_block.file.url
    end

    test "#attachable_type" do
      assert_equal "Cms::AbstractFileBlock", @file_block.attachable_type
    end

    test "Loads attachments for as_of_versions" do
      found = @file_block.as_of_version(1)
      assert_equal 1, found.attachments.size
    end

    test "attachment_version_path for older versions" do
      @file_block.file.data_file_path = "/new-path.txt"
      @file_block.update_attributes(:name => "Force an update", :publish_on_save => true)
      reset(:file_block)

      assert_equal '/new-path.txt', @file_block.file.data_file_path

      v1 = @file_block.as_of_version(1)
      assert_equal "/cms/attachments/#{v1.file.id}?version=#{v1.file.version}", v1.file.attachment_version_path
    end

    test "updates to #attachments automatically autosave" do
      @file_block.attachments[0].data_file_path = "/new-path.txt"
      assert @file_block.attachments[0].changed?

      @file_block.name = "Force an update"
      @file_block.publish_on_save = true
      @file_block.save!
      reset(:file_block)

      assert_equal 1, @file_block.attachments.size, "Should still have an attachment after updating it."
      assert_equal "/new-path.txt", @file_block.attachments[0].data_file_path
    end

    test "update via nested assignment" do
      @file_block.update_attributes(:name => "Force an update", :attachments_attributes => {"0" => {:data_file_path => "/new-path.txt", :attachment_name => "file", :id => @file_block.attachments[0].id}})
      assert_equal "/new-path.txt", @file_block.attachments[0].data_file_path
    end

  end
  class ExistingFileBlockTest < ActiveSupport::TestCase
    def setup
      @file_block = create(:file_block)
    end

    def test_archiving
      assert @file_block.update_attributes(:archived => true)
      assert @file_block.attachments[0].archived?
    end

    def test_destroy
      @file_block.destroy
      assert_nil Cms::Attachment.find_live_by_file_path("/test.txt")
    end
  end

end

