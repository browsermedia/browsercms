require "minitest_helper"

describe Cms::Page do
  let(:block) { create(:html_block, :name => "Hello, World!") }
  let(:page) { create(:page) }
  let(:page_with_draft) do
    page.update_attributes(name: 'Version 2', as: :draft)
    page
  end
  let(:archived_page) do
    p = create(:page)
    p.archive!
    p
  end

  describe '#find_live' do
    it "should return the latest published version of a page" do
      found = Cms::Page.find_live(page_with_draft.path)
      found.version.must_equal 1
      found.name.wont_equal 'Version 2'
    end

    it "should raise error if non-existent path" do
      ->{Cms::Page.find_live("/non-existent")}.must_raise Cms::Errors::ContentNotFound
    end

    it "should raise error for archived pages" do
      ->{Cms::Page.find_live(archived_page.path)}.must_raise Cms::Errors::ContentNotFound
    end
  end
  describe '#find_live_by_path' do

    it "should return nil for archived page" do
      found = Cms::Page.find_live_by_path(archived_page.path)
      found.must_be_nil
    end

    it "should return nil if not found" do
      found = Cms::Page.find_live_by_path("/non-existent-path")
      found.must_be_nil
    end

    it "should not find draft if path was changed" do
        @page = create(:page, :path => '/old-path')
        @page.update_attributes(:path => '/new-path', :publish_on_save => false)
        assert_equal @page, Cms::Page.find_live_by_path('/old-path')
        assert_nil Cms::Page.find_live_by_path('/new-path')
    end
  end


  describe '#find_draft' do

    it "should return the latest draft of the page" do
      expected = page_with_draft

      found = Cms::Page.find_draft(expected.id)
      found.name.must_equal expected.name
      found.version.must_equal 2
    end

    it "should find by path" do
      expected = page_with_draft

      found = Cms::Page.find_draft(expected.path)
      found.name.must_equal expected.name
      found.version.must_equal 2
    end

    it "should throw error if page not found" do
      proc { Cms::Page.find_draft('/non-existent-path')}.must_raise Cms::Errors::DraftNotFound
    end

  end

  describe '.move_connector' do
    it "should not publish the page" do
      page.add_content(block)
      page.move_connector(first_connector_for(block), :up)

      page.live_version.version.must_equal 1
    end
  end

  describe '.remove_connector' do
    it "should not publish the page" do
      page.add_content(block)
      page.remove_connector(first_connector_for(block))

      page.live_version.version.must_equal 1
    end
  end

  describe '.revert_to' do
    it "should not publish the page" do
      page.add_content(block)
      page.revert_to 1

      page.live_version.version.must_equal 1
    end
  end

  describe 'revision comments' do
    let(:page) { create(:page, :section => root_section, :name => "V1") }
    it "should start with a 'Created' comment" do
      page.live_version.version_comment.must_equal 'Created'
    end

    it "should not create a comment when no changes occurred during saving" do
      page.save
      page.live_version.version_comment.must_equal 'Created'
      page.as_of_version(page.version).live_version.version_comment.must_equal 'Created'
    end

    it "should create update comment for draft" do
      page.update_attributes(name: "V2", publish_on_save: false)
      assert_equal 'Changed name', page.draft.version_comment
      assert_equal 'Created', page.live_version.version_comment
    end

    it "should record when content is added to pages" do
      page.create_connector(block, "main")
      assert_equal "Html Block 'Hello, World!' was added to the 'main' container",
                   page.draft.version_comment
      assert_equal 'Created', page.live_version.version_comment
      assert_equal 2, page.draft.version
    end

    it "should record when content is moved up within pages" do
      page.add_content(block)
      page.add_content(create(:html_block, :name => "Another block"))

      page.move_connector_down(first_connector_for(block))

      assert_equal "Html Block 'Hello, World!' was moved down within the 'main' container",
                   page.draft.version_comment
      assert_equal 'Created', page.live_version.version_comment
    end

    it "should record when content is removed from a page" do
      page.add_content(block)
      page.remove_connector(first_connector_for(block))
      assert_equal "Html Block 'Hello, World!' was removed from the 'main' container",
                   page.draft.version_comment
      assert_equal 'Created', page.live_version.version_comment
    end

    it "should record when a page is reverted" do
      page.add_content(block)
      page.revert_to(1)
      assert_equal "Reverted to version 1",
                   page.reload.draft.version_comment
      assert_equal 'Created', page.live_version.version_comment
      assert_equal "Reverted to version 1", page.draft.version_comment
    end

  end

  def first_connector_for(content)
    page.connectors.for_page_version(page.draft.version).for_connectable(content).first
  end
end
