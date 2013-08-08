require 'test_helper'

module Cms
  class CreatingPageTest < ActiveSupport::TestCase

    test "#landing_page? if matches parent's path'" do
      section = create(:section, path: "/about")
      landing_page = create(:page, path: "/about", parent: section)
      assert landing_page.landing_page?
    end

    test "home?" do
      @page = create(:page, path: "/")
      assert @page.home?
    end

    test "Testing Database should be empty and have no pages" do
      assert_nil Cms::Page.with_path("/").first
    end

    def test_creating_a_page_and_updating_the_attributes
      @page = Cms::Page.new(
          :name => "Test",
          :path => "test",
          :section => root_section
      )

      assert @page.save
      assert_path_is_unique

      @page.update_attributes(name: "Test v2", publish_on_save: false)
      page = Cms::Page.find_live_by_path("/test")
      assert_equal "Test", page.name
      assert_equal 1, page.version
    end

    test "Creating a page builds a section node" do
      @page = Page.create!(:name => "Hello", :path => "/hello", :section => create(:root_section))
      assert_not_nil @page.section_node
    end

    test "page with no parent" do
      @page = Page.new
      assert_nil @page.parent
    end

    test "#section is alias for #parent" do
      @page = Page.new
      assert_nil @page.section
    end


    protected
    def assert_path_is_unique
      page = build(:page, :path => @page.path)
      assert_not_valid page
      assert_has_error_on page, :path
    end

  end

  class VersionTest < ActiveSupport::TestCase

    def setup
      @page = create(:public_page)
      @another_page = create(:public_page)
    end

    test "#latest_version set set when page is created" do
      assert_equal 1, @page.version
      assert_equal 1, @page.latest_version
    end

    test "#latest_version is incremented when page#update occurs" do
      @page.name = "New"
      @page.save_draft
      @page.reload

      assert_equal 1, @page.version
      assert_equal 2, @page.latest_version

      assert_equal 1, @another_page.reload.latest_version, "Should only update its own version, not other tables"
    end

    test "live? should be false for 'new' objects" do
      refute Cms::Page.new.live?
    end

    test "live? using latest version" do
      assert @page.live?

      @page.update_attributes(:name => "New", :publish_on_save => false)
      @page.reload
      refute @page.live?

      @page.publish!
      @page.reload
      assert @page.live?
    end

    test "live? as_of_version" do
      @page.update_attributes(:name => "New")
      @page.publish!

      v1 = @page.as_of_version(1)
      assert v1.live?
    end
  end

  class PageLayoutTest < ActiveSupport::TestCase

    def setup
      @page = build(:page, :template_file_name => 'subpage.html.erb')
    end

    test "#template_file_name" do
      assert_equal 'subpage.html.erb', @page.template_file_name
    end

    test "#template_name" do
      assert_equal 'Subpage (html/erb)', @page.template_name
    end

    test "#template for File system templates" do
      assert_nil @page.template
    end

    test "#layout for full templates" do
      assert_equal 'templates/subpage', @page.layout
    end

    test "#layout_name" do
      assert_equal 'subpage', @page.layout_name
    end

    test "#layout for mobile" do
      assert_equal 'mobile/subpage', @page.layout(:mobile)
    end

  end

  class PageTest < ActiveSupport::TestCase

    def test_creating_page_with_reserved_path
      @page = Cms::Page.new(:name => "FAIL", :path => "/cms")
      assert_not_valid @page
      assert_has_error_on(@page, :path, "is invalid, '/cms' a reserved path")

      @page = Cms::Page.new(:name => "FAIL", :path => "/cache")
      assert_not_valid @page
      assert_has_error_on(@page, :path, "is invalid, '/cache' a reserved path")

      @page = Cms::Page.new(:name => "FTW", :path => "/whatever")

      assert_valid @page
    end

    def test_creating_page_with_trailing_slash
      @page = build(:page, :path => "/slashed/")
      @page.save
      assert_equal @page.path, "/slashed"

      @page = build(:page, :path => "/slashed/loooong/path/")
      @page.save
      assert_equal @page.path, "/slashed/loooong/path"
    end

    test "It should be possible to create a new page, using the same path as a previously deleted page" do
      p = Time.now.to_f.to_s #use a unique, but consistent path

      @page = create(:public_page, :path => "/#{p}")
      @page.destroy

      @page2 = create(:public_page, :path => "/#{p}")
      assert_not_equal(@page, @page2)
    end

    test "Find by live path should not located deleted blocks, even if they share paths with live ones" do
      @page = create(:page, :path => '/foo')
      @page.mark_as_deleted!
      assert_nil Cms::Page.find_live_by_path('/foo')

      @new_page = build(:page, :path => '/foo')
      assert_nil Cms::Page.find_live_by_path('/foo')

      @new_page.save!
      reset(:new_page)
      assert_equal @new_page, Cms::Page.find_live_by_path('/foo')
      assert_not_equal @page, @new_page
    end

    def test_path_normalization
      page = build(:page, :path => 'foo/bar')
      assert_valid page
      assert_equal "/foo/bar", page.path

      page = build(:page, :path => '/foo/bar')
      assert_valid page
      assert_equal "/foo/bar", page.path
    end

    def test_container_live
      page = create(:page)
      published = create(:html_block)
      unpublished = create(:html_block, publish_on_save: false)
      page.add_content(published, "main")
      page.add_content(unpublished, "main")
      assert !page.container_published?("main")
      assert unpublished.publish
      assert page.container_published?("main")
    end

    def test_move_page_to_another_section
      page = create(:public_page)
      new_section = create(:public_section)

      assert_not_equal new_section, page.section
      page.section = new_section
      assert page.save
      assert_equal new_section, page.section
    end

    def test_deleting_page
      page = create(:page)
      page_count = Cms::Page.count_with_deleted

      page_version_count = page.versions.count
      assert !page.deleted?

      page.destroy

      assert_equal page_count, Cms::Page.count_with_deleted
      assert_incremented page_version_count, page.versions.count
      assert page.deleted?
      assert_raise ActiveRecord::RecordNotFound do
        Cms::Page.find(page.id)
      end

    end

    def test_adding_a_block_to_a_page_puts_page_in_draft_mode
      @page = create(:page, :section => root_section, :publish_on_save => true)
      @block = create(:html_block, :publish_on_save => true)
      reset(:page, :block)
      assert @page.published?
      assert @block.published?
      @page.add_content(@block, "main")
      reset(:page, :block)
      refute @page.live?, "Page should be unpublished after adding content"
    end

    def test_reverting_and_then_publishing_a_page
      @page = create(:page, :section => root_section, :publish_on_save => true)

      @block = create(:html_block,
                      :connect_to_page_id => @page.id,
                      :connect_to_container => "main")
      @page.publish

      reset(:page, :block)

      assert_equal 2, @page.version
      assert_equal 1, @page.connectors.for_page_version(@page.version).count

      @block.update_attributes(:content => "Something else")
      @page.publish!
      reset(:page, :block)

      assert_equal 1, @page.connectors.for_page_version(@page.version).count
      assert_equal 2, @block.version
      assert_equal 3, @page.version
      assert @block.live?
      assert @page.live?

      @page.revert_to(2)
      reset(:page, :block)

      assert_equal 3, @page.version
      assert_equal 4, @page.draft.version
      assert_equal 2, @block.version
      assert_equal 3, @block.draft.version
      assert_equal 1, @page.connectors.for_page_version(@page.version).count
      assert_equal 1, @page.connectors.for_page_version(@page.draft.version).count
      assert !@page.live?
      assert !@block.live?

    end

  end

  class UserStampingTest < ActiveSupport::TestCase

    def setup
      @first_guy = create(:user, :login => "first_guy")
      @next_guy = create(:user, :login => "next_guy")
      Cms::User.current = @first_guy
    end

    def teardown
      Cms::User.current = nil
    end

    def test_user_stamps_are_applied_to_versions
      page = create(:page, :name => "Original Value")

      assert_equal page, page.draft.page
      assert_equal @first_guy, page.updated_by

      Cms::User.current = @new_guy

      page.update_attributes(:name => "Something Different", :publish_on_save => false)

      assert_equal "Something Different", page.draft.name
      assert_equal "Original Value", page.reload.name
      assert_equal "Original Value", page.versions.first.name
      assert_equal @first_guy, page.versions.first.updated_by
      assert_equal @new_guy, page.versions.last.updated_by
      assert_equal 2, page.versions.count
    end

  end

  class PageInSectionTest < ActiveSupport::TestCase

    def setup
      @root = create(:root_section, :name => "First Section")
      @football_section = create(:public_section, :name => "Football", :parent => @root)
      @baseball_section = create(:public_section, :name => "Baseball", :parent => @root)

      @football_page = create(:public_page, :section => @football_section)
      @baseball_page = create(:public_page, :section => @baseball_section)
    end

    test "in_section if immediate parent section is included" do
      assert @football_page.in_section?("Football")
      assert !@baseball_page.in_section?("Football")
    end

    test "in_section if immediate parent's name is included" do
      assert @football_page.in_section?("Football")
      assert !@baseball_page.in_section?("Football")
    end

    test "in_section if any ancestor is included" do
      assert @football_page.in_section?(@root)
      assert @baseball_page.in_section?(@root)
      assert @football_page.in_section?("First Section")
      assert @baseball_page.in_section?("First Section")
    end

    test "#top_level_section works for page in root section" do
      page = create(:public_page, :parent => root_section)
      assert_equal root_section, page.top_level_section
    end

    test "#top_level_section" do
      assert_equal @football_section, @football_page.top_level_section
      assert_equal @baseball_section, @baseball_page.top_level_section

      second_level_section = create(:public_section, :parent => @football_section)
      second_level_page = create(:public_page, :section => second_level_section)
      assert_equal @football_section, second_level_page.top_level_section
    end

    test "#top_level_section caches result to avoid repeated requests" do
      top = @football_page.top_level_section
      assert_equal top.object_id, @football_page.top_level_section.object_id
    end
  end

  class PageWithAssociatedBlocksTest < ActiveSupport::TestCase
    def setup
      super
      @page = create(:page, :section => root_section, :name => "Bar")
      @block = create(:html_block)
      @other_connector = create(:connector, :connectable => @block, :connectable_version => @block.version)
      @page_connector = create(:connector, :page => @page, :page_version => @page.version, :connectable => @block, :connectable_version => @block.version)
    end

    # It should create a new page version and a new connector
    def test_updating_the_page_with_changes
      Cms::Page.delete_all
      connector_count = Cms::Connector.count

      page_version = @page.version
      @page.update_attributes(name: "Foo", publish_on_save: false)

      assert_incremented connector_count, Cms::Connector.count
      assert_equal page_version, @page.version
      assert_incremented page_version, @page.draft.version
    end

    # It should not create a new page version or a new connector
    def test_updating_the_page_without_changes
      connector_count = Cms::Connector.count
      page_version = @page.version

      @page.update_attributes(:name => @page.name)

      assert_equal connector_count, Cms::Connector.count

      assert_equal page_version, @page.version
    end

    # Verifies that 'after_destroy' callbacks happen on Page/SoftDeleting objects, such that
    # a deleted page is disassociated with any blocks it was connected to.
    test "Destroying a page with a block should remove its connectors from the database completely." do

      connector_count = Cms::Connector.count
      assert Cms::Connector.exists?(@page_connector.id)
      assert Cms::Connector.exists?(@other_connector.id)

      @page.destroy

      assert_decremented connector_count, Cms::Connector.count
      assert !Cms::Connector.exists?(@page_connector.id)
      assert Cms::Connector.exists?(@other_connector.id)
      assert Cms::HtmlBlock.exists?(@block.id)
      assert !@block.deleted?
    end


  end

  class AddingBlocksTest < ActiveSupport::TestCase

    def setup
      @page = create(:page)
      @block = create(:html_block)
      @original_versions_count = @page.versions.count
      @connector_count = Cms::Connector.count

      @connector = @page.create_connector(@block, "main")
      reset(:page, :block)
    end


    test "Adding a block to a page without publishing" do
      assert_equal 1, @page.version, "The unpublished page should still be version 1"
      assert_equal 2, @connector.page_version, "The connector should point to version 2 of the page"
      assert_equal 1, @connector.connectable_version, "Connector should point to version 1 of the block"
      assert_incremented @original_versions_count, @page.versions.count # "There should be a new version of the page"
      assert_equal 1, @page.connectors.for_page_version(@page.draft.version).count

      assert_equal @connector_count + 1, Cms::Connector.count, "Adding the first block to a page should add exactly one connector"
    end

    test "Adding additional blocks to a page" do
      block2 = create(:html_block)


      conn = @page.create_connector(block2, "main")

      assert_equal 1, @page.version
      assert_equal 1, conn.connectable_version
      assert_equal 3, @page.versions.count, "Should be three versions of the page now"
      assert_equal 3, @page.draft.version, "Latest draft of a page should be 3"
      assert_equal 2, @page.connectors.for_page_version(@page.draft.version).count
      assert_equal @connector_count + 3, Cms::Connector.count, "Adding a second block to an existing page should add 3 total connectors."
    end

    test "Creating a new block to a page should update all existing connectors to the new page version." do
      Rails.logger.warn "Creating a new connector"
      @page.create_connector(create(:html_block), "main")
      expected_version = 3
      Rails.logger.warn "Done"
      connectors = @page.connectors.for_page_version(expected_version)
      assert_equal expected_version, connectors[0].page_version, "There should be two connectors with the same version as the page"
      assert_equal expected_version, connectors[1].page_version
      assert_equal 2, connectors.count, "There should be two connectors total for the page for this version (3) of the page."

    end
  end

  class AddingBlocksToPageTest < ActiveSupport::TestCase


    def test_that_it_works
      @page = create(:page, :section => root_section)
      @block = create(:html_block)
      @block2 = create(:html_block)
      @first_conn = @page.create_connector(@block, "testing")
      @second_conn = @page.create_connector(@block2, "testing")

      page_version_count = @page.versions.count
      connector_count = Cms::Connector.count

      @conn = @page.create_connector(@block2, "testing")

      assert_equal 1, @page.reload.version
      assert_equal 4, @conn.page_version
      assert_equal 1, @conn.connectable_version
      assert_incremented page_version_count, @page.versions.count
      assert_equal 3, @page.connectors.for_page_version(@page.draft.version).count
      assert_equal connector_count + 3, Cms::Connector.count


      # should leave the previous connectors untouched
      @conns = @page.connectors.all(:conditions => ["page_version < 4"], :order => "id")

      assert_equal 3, @conns.size

      assert_properties @conns[0], {
          :connectable => @block,
          :page => @page,
          :page_version => 2,
          :connectable_version => 1
      }

      assert_properties @conns[1], {
          :connectable => @block,
          :page => @page,
          :page_version => 3,
          :connectable_version => 1
      }

      assert_properties @conns[2], {
          :connectable => @block2,
          :page => @page,
          :page_version => 3,
          :connectable_version => 1
      }

      @conns = @page.connectors.for_page_version(4).all(:order => "id")
      assert_equal 3, @conns.size

      assert_properties @conns[0], {
          :connectable => @block,
          :page => @page,
          :page_version => 4,
          :connectable_version => 1
      }

      assert_properties @conns[1], {
          :connectable => @block2,
          :page => @page,
          :page_version => 4,
          :connectable_version => 1
      }

      assert_properties @conns[2], {
          :connectable => @block2,
          :page => @page,
          :page_version => 4,
          :connectable_version => 1
      }

    end
  end

  class PageWithTwoBlocksTest < ActiveSupport::TestCase
    def setup
      super
      @page = create(:page, :section => root_section)
      @foo_block = create(:html_block, :name => "Foo Block")
      @bar_block = create(:html_block, :name => "Bar Block")
      @page.create_connector(@foo_block, "whatever")
      @page.reload
      @page.create_connector(@bar_block, "whatever")
      @page.reload
    end

    def test_editing_one_of_the_blocks_creates_a_new_version_of_the_page
      page_version = @page.draft.version
      @foo_block.update_attributes(:name => "Something Else")
      assert_incremented page_version, @page.draft.version
    end

    # A page that had 2 blocks added to it and then had them removed,
    # when reverting to the previous version,
    # should restore the connectors from the version being reverted to
    def test_removing_and_reverting_to_previous_version
      remove_both_connectors!

      connector_count = Cms::Connector.count

      @page.revert

      assert_incremented connector_count, Cms::Connector.count
      assert_properties @page.reload.connectors.for_page_version(@page.draft.version).first, {
          :page => @page,
          :page_version => 6,
          :connectable => @bar_block,
          :connectable_version => 1,
          :container => "whatever"}
    end

    # A page that had 2 blocks added to it and then had then removed,
    # when reverting to the version that had both connectors,
    # should restore the connectors that version
    def test_removing_and_reverting_to_version_with_both_connectors
      remove_both_connectors!

      connector_count = Cms::Connector.count

      @page.revert_to(3)

      assert_equal connector_count + 2, Cms::Connector.count

      foo, bar = @page.reload.connectors.for_page_version(@page.draft.version).find(:all, :order => "#{Cms::Connector.table_name}.position")

      assert_properties foo, {
          :page => @page,
          :page_version => 6,
          :connectable => @foo_block,
          :connectable_version => 1,
          :container => "whatever"}
      assert_properties bar, {
          :page => @page,
          :page_version => 6,
          :connectable => @bar_block,
          :connectable_version => 1,
          :container => "whatever"}

    end

    def test_updating_one_of_the_blocks_and_reverting_to_version_before_the_update

      target_version = @page.draft.version
      @foo_block.update_attributes!(:name => "Foo V2", :publish_on_save => false)
      @page.reload

      page_version = @page.draft.version
      foo_block_version = @foo_block.draft.version

      @page.revert_to(target_version)

      assert_incremented page_version, @page.draft.version
      assert_incremented foo_block_version, @foo_block.draft.version
      assert_equal "Foo Block", @page.connectors.for_page_version(@page.draft.version).reload.first.connectable.name, "This might be correct now. When you revert"
    end

    protected
    def remove_both_connectors!
      @page.remove_connector(@page.connectors.for_page_version(@page.draft.version).first(:order => "#{Cms::Connector.table_name}.position"))
      @page.remove_connector(@page.connectors.for_page_version(@page.draft.version).first(:order => "#{Cms::Connector.table_name}.position"))
    end


  end

  class PageWithBlockTest < ActiveSupport::TestCase
    def setup
      @page = create(:page, :section => root_section)
      @block = create(:html_block)
      @conn = @page.add_content(@block, "bar")
      @page.publish!
      @conn = first_connector_for(@page, @block)
    end

    def first_connector_for(page, block)
      page.connectors.for_page_version(page.version).for_connectable(block).first
    end

    test ".current_connectors finds all connectors for current version of the page" do
      assert_equal [@conn], @page.current_connectors
    end

    test ".current_connectors(name) returns connectors for given container" do
      new_conn = @page.add_content(create(:html_block), "main")
      @page.publish!
      assert_equal [new_conn], @page.current_connectors(:main)
      assert_equal [first_connector_for(@page, @block)], @page.current_connectors(:bar)

    end
    test ".contents finds all non-deleted content items for the current version of the page" do
      assert_equal [@conn.connectable], @page.contents
    end

    def test_removing_connector
      page_version = @page.draft.version
      page_version_count = Cms::Page::Version.count
      assert @page.published?

      @page.remove_connector(@conn)

      assert_incremented page_version_count, Cms::Page::Version.count

      assert_incremented page_version, @page.draft.version

      conns = @page.connectors.for_page_version(@page.draft.version-1).all
      assert_equal 1, conns.size

      assert_properties conns.first, {
          :page => @page,
          :page_version => page_version,
          :connectable => @block,
          :connectable_version => @block.version
      }

      assert @page.reload.connectors.for_page_version(@page.draft.version).empty?
      assert !@page.live?
    end

    def test_removing_multiple_connectors
      @block2 = create(:html_block)
      @conn2 = @page.create_connector(@block2, "bar")
      @conn3 = @page.create_connector(@block2, "foo")
      #Need to get the new connector that matches @conn2, otherwise you will delete an older version, not the latest connector
      @conn2 = Cms::Connector.first(:conditions => {:page_id => @page.reload.id, :page_version => @page.draft.version, :connectable_id => @block2.id, :connectable_version => @block2.version, :container => "bar"})
      @page.remove_connector(@conn2)

      page_version_count = Cms::Page::Version.count
      page_version = @page.draft.version
      page_connector_count = @page.connectors.for_page_version(@page.draft.version).count

      @conn = Cms::Connector.first(:conditions => {:page_id => @page.reload.id, :page_version => @page.draft.version, :connectable_id => @block2.id, :connectable_version => @block2.version, :container => "foo"})
      @page.remove_connector(@conn)
      @page.reload

      assert_incremented page_version_count, Cms::Page::Version.count
      assert_incremented page_version, @page.draft.version
      assert_decremented page_connector_count, @page.connectors.for_page_version(@page.draft.version).count

      conns = Cms::Connector.where("page_id = ?", @page.id).order("id")

      assert_equal 9, conns.size

      assert_properties conns[0], {:page => @page, :page_version => 2, :connectable => @block, :connectable_version => 1, :container => "bar", :position => 1}
      assert_properties conns[1], {:page => @page, :page_version => 3, :connectable => @block, :connectable_version => 1, :container => "bar", :position => 1}
      assert_properties conns[2], {:page => @page, :page_version => 3, :connectable => @block2, :connectable_version => 1, :container => "bar", :position => 2}
      assert_properties conns[3], {:page => @page, :page_version => 4, :connectable => @block, :connectable_version => 1, :container => "bar", :position => 1}
      assert_properties conns[4], {:page => @page, :page_version => 4, :connectable => @block2, :connectable_version => 1, :container => "bar", :position => 2}
      assert_properties conns[5], {:page => @page, :page_version => 4, :connectable => @block2, :connectable_version => 1, :container => "foo", :position => 1}
      assert_properties conns[6], {:page => @page, :page_version => 5, :connectable => @block, :connectable_version => 1, :container => "bar", :position => 1}
      assert_properties conns[7], {:page => @page, :page_version => 5, :connectable => @block2, :connectable_version => 1, :container => "foo", :position => 1}
      assert_properties conns[8], {:page => @page, :page_version => 6, :connectable => @block, :connectable_version => 1, :container => "bar", :position => 1}
    end

  end

  class UnpublishedPageWithOnePublishedAndOneUnpublishedBlockTest < ActiveSupport::TestCase
    def setup
      @page = create(:page, :section => root_section)
      @published_block = create(:html_block, :name => "Published")
      @unpublished_block = create(:html_block, :name => "Unpublished")
      @page.create_connector(@published_block, "main")
      @page.create_connector(@unpublished_block, "main")
      @published_block.publish!
      @page.reload
    end

    def test_publishing_the_block
      @unpublished_block.publish!
      assert @unpublished_block.reload.published?
      @page.reload
      assert !@page.live?
    end

    def test_publishing_the_page
      page_version_count = Cms::Page::Version.count
      unpublished_block_version_count = @unpublished_block.versions.count
      published_block_version_count = @published_block.versions.count

      @page.publish!

      assert_equal page_version_count, Cms::Page::Version.count
      assert_equal unpublished_block_version_count, @unpublished_block.versions.count
      assert_equal published_block_version_count, @published_block.versions.count
      assert @page.live?
      assert @unpublished_block.reload.live?
      assert @published_block.reload.live?
    end

  end

  class RevertingABlockThatIsOnMultiplePagesTest < ActiveSupport::TestCase
    def test_that_it_reverts_both_pages

      # 1. Create a new page (Page 1, v1)
      @page1 = create(:page, :name => "Page 1")
      assert_equal 1, @page1.version

      # 2. Create a new page (Page 2, v1)
      @page2 = create(:page, :name => "Page 2")

      # 3. Add a new html block to Page 1. Save, don't publish. (Page 1, v2)
      @block = create(:html_block, :name => "Block v1",
                      :connect_to_page_id => @page1.id, :connect_to_container => "main")
      reset(:page1, :page2, :block)
      assert_equal 2, @page1.draft.version
      assert_equal 1, @page2.draft.version

      # 4. Goto page 2, and select that block. (Page 2, v2)
      @page2.create_connector(@block, "main")
      reset(:page1, :page2, :block)
      assert_equal 2, @page1.draft.version
      assert_equal 2, @page2.draft.version

      # 5. Edit the block (Page 1, v3, Page 2, v3, Block v2)
      @block.update_attributes!(:name => "Block v2", :publish_on_save => false)
      reset(:page1, :page2, :block)
      assert_equal 3, @page1.draft.version
      assert_equal 3, @page2.draft.version
      assert_equal 2, @block.draft.version

      # 6. Revert page 1 to version 2. (Page 1, v4, Page 2, v4, Block v3)
      @page1.revert_to(2)
      reset(:page1, :page2, :block)
      assert_equal 4, @page1.draft.version
      assert_equal 3, @block.draft.version
      assert_equal 4, @page2.draft.version

      # Expected: Both page 1 and 2 will display the same version of the block (v1).
      assert_equal "Block v1", @page1.connectors.first.connectable.name
      assert_equal "Block v1", @page2.connectors.first.connectable.name

    end

  end

  class ViewingAPreviousVersionOfAPageTest < ActiveSupport::TestCase

    def test_that_it_shows_the_correct_version_of_the_blocks_it_is_connected_to
      # 1. Create Page A (v1)
      @page = create(:page, :section => root_section)

      # 2. Add new Html Block A to Page A (Page A v2, Block A v1)
      @block = create(:html_block, :name => "Block 1", :connect_to_page_id => @page.id, :connect_to_container => "main")
      reset(:page, :block)
      assert_equal 2, @page.draft.version
      assert_equal 1, @block.draft.version

      # 3. Publish Page A (Page A v3, Block A v2)
      @page.publish!
      reset(:page, :block)
      assert_equal 2, @page.draft.version
      assert_equal 1, @block.draft.version

      # 4. Edit Block A (Page A v4, Block A v3)
      @block.update_attributes!(:name => "Block 2", :publish_on_save => false)
      reset(:page, :block)
      assert_equal 2, @page.version
      assert_equal 3, @page.draft.version
      assert_equal 2, @block.draft.version

      # Open Page A in a different browser (as guest)
      @live_page = Cms::Page.find_live_by_path(@page.path)
      assert_equal 2, @live_page.version
      assert_equal "Block 1", @live_page.connectors.for_page_version(@live_page.version).first.connectable.live_version.name

    end
  end

  class PortletsDontHaveDraftsTest < ActiveSupport::TestCase

    def test_connectors_with_portlets_should_correctly_be_copied
      @page = create(:page, :section => root_section)
      @portlet = TagCloudPortlet.create(:name => "Portlet", :connect_to_page_id => @page.id, :connect_to_container => "main")

      # Check some assumptions.
      assert_equal 2, @page.draft.version, "Verifying that adding a portlet correctly increments page version."
      connectors = Cms::Connector.for_connectable(@portlet)
      assert_equal 1, connectors.size, "This portlet should have only 1 connector."

      # Verifies that an exception is not thrown while removing connectors
      @page.remove_connector(connectors[0])

      assert_equal 3, @page.draft.version
      assert @page.reload.connectors.for_page_version(@page.draft.version).empty?, "Verify that all connectors for the latest page are removed."
    end
  end
end
