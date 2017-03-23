require 'test_helper'

class HtmlBlockTest < ActiveSupport::TestCase

  test "#model_form_name" do
    assert_equal "html_block", Cms::HtmlBlock.content_type.param_key
  end
  test "#paginate" do
    red = create(:html_block, name: 'red')
    blue = create(:html_block, name: 'blue')

    results = Cms::HtmlBlock.paginate(page: 1, per_page: 1)
    assert_equal 1, results.size
    assert_equal red, results.first
  end

  test "template_path" do
    assert_equal "cms/html_blocks/render", Cms::HtmlBlock.template_path
  end

  test "default table_name" do
    assert_equal "cms_html_blocks", Cms::HtmlBlock.table_name
  end

  test ".search" do
    find = Cms::HtmlBlock.create!(:name => "Test A", content: "Alpha")
    dont_find = Cms::HtmlBlock.create!(:name => "Test B", content: "Bravo")

    assert_equal [find], Cms::HtmlBlock.search({term: 'Test A'}).to_a
    assert_equal [find], Cms::HtmlBlock.search({term: 'Alpha', include_body: true}).to_a
  end

  def test_searchable
    @a1 = create(:html_block, :name => "a1", :content => "a one")
    @a2 = create(:html_block, :name => "a2", :content => "a two")
    @b1 = create(:html_block, :name => "b1", :content => "b one")
    @b2 = create(:html_block, :name => "b2", :content => "b two")

    assert Cms::HtmlBlock.searchable?
    assert_equal [@a2, @b2], Cms::HtmlBlock.search("2").to_a
    assert Cms::HtmlBlock.search(:term => "one").to_a.empty?
    assert_equal [@a1, @b1], Cms::HtmlBlock.search(:term => "one", :include_body => true).to_a
    assert Cms::HtmlBlock.search(nil).include?(@b2)
  end

  test "form" do
    type = Cms::ContentType.new(:name => "Cms::HtmlBlock")
    assert_equal "cms/html_blocks/form", type.form
  end

  def test_create
    @page = create(:page)
    @html_block = create(:html_block, :connect_to_page_id => @page.id, :connect_to_container => "test")
    assert_equal 1, @page.reload.connectors.count
    assert_equal @page, @html_block.connected_page
    assert_equal @page.id, @html_block.connect_to_page_id
    assert_equal "test", @html_block.connect_to_container
  end

  def test_versioning
    assert Cms::HtmlBlock.versioned?

    @html_block = create(:html_block, :name => "Original Value")
    assert_equal @html_block, @html_block.versions.last.html_block

    # Updates should make a new version
    assert @html_block.update_attributes(:name => "Something Different")
    assert_equal @html_block, @html_block.versions.last.html_block
    assert_equal "Something Different", @html_block.versions.last.name
    assert_equal "Something Different", @html_block.name
    assert_equal "Original Value", @html_block.versions.first.name

    # Updating with no changes should not generate a new version
    html_block_version_count = @html_block.versions.count
    @html_block.update_attributes(:name => "Something Different")
    assert_equal html_block_version_count, @html_block.versions.count

    # deleting should create a new version
    html_block_count = Cms::HtmlBlock.count_with_deleted
    html_block_version_count = @html_block.versions.count
    assert !@html_block.deleted?

    @html_block.destroy

    assert_equal html_block_count, Cms::HtmlBlock.count_with_deleted
    assert_incremented html_block_version_count, @html_block.versions.count
    assert @html_block.deleted?

  end

  def test_reverting
    # We need a block with a version that was created in the past
    @v1_created_at = Time.zone.now - 5.days
    @html_block = create(:html_block, :name => "Version One", :created_at => @v1_created_at)

    # Make the version be created in the past as well
    v1 = @html_block.versions.last
    v1.created_at = @v1_created_at
    v1.save

    # Make a new version
    @html_block.update_attributes(:name => "Version Two", :publish_on_save => false)
    @v2_created_at = @html_block.versions.last.created_at

    assert_equal "Version Two", @html_block.name
    assert_equal @v1_created_at.to_i, @html_block.find_version(1).created_at.to_i
    assert_equal @v2_created_at.to_i, @html_block.find_version(2).created_at.to_i

    @html_block.revert_to 1
    @html_block.reload

    assert_equal 3, @html_block.draft.version
    assert_equal "Version One", @html_block.name
    assert_equal @v1_created_at.to_i, @html_block.find_version(1).created_at.to_i
    assert_equal @v2_created_at.to_i, @html_block.find_version(2).created_at.to_i
    assert @html_block.find_version(3).created_at.to_i >= @v2_created_at.to_i
    assert_equal @v1_created_at.to_i, @html_block.created_at.to_i

    # version is required for revert_to
    html_block_version_count = Cms::HtmlBlock::Version.count
    ex = assert_raises RuntimeError do
      @html_block.revert_to nil
    end
    assert_equal "Version parameter missing", ex.message
    assert_equal html_block_version_count, Cms::HtmlBlock::Version.count

    html_block_version_count = Cms::HtmlBlock::Version.count
    ex = assert_raise RuntimeError do
      @html_block.revert_to 42
    end
    assert_equal "Could not find version 42", ex.message
    assert_equal html_block_version_count, Cms::HtmlBlock::Version.count
  end

  def test_previous_version
    @html_block = create(:html_block, :name => "V1")
    @html_block.update_attributes(:name => "V2", :publish_on_save => false)
    @version = @html_block.as_of_version 1

    assert_equal Cms::HtmlBlock, @version.class
    assert_equal "V1", @version.name
    assert_equal 1, @version.version
    assert_equal @html_block.id, @version.id

    # We can't freeze the version because we need to be able to load assocations
    refute @version.frozen?
    refute @version.live?
    refute @html_block.live?
  end

end
