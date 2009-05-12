require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::HtmlBlocksControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  
  def setup
    login_as_cms_admin
    @block = Factory(:html_block, :name => "Test", :content => "I worked.", :publish_on_save => true)
  end
  
  def test_new
    get :new
    assert_response :success    
    assert_select "h1", "Add New Text"
  end

  def test_add_to_page
    @page = Factory(:page, :path => "/test", :section => root_section)
    get :new, :html_block => {:connect_to_page_id => @page.id, :connect_to_container => "test"}
    assert_response :success
    assert_select "input[name=?][value=?]", "html_block[connect_to_page_id]", @page.id.to_s
    assert_select "input[name=?][value=?]", "html_block[connect_to_container]", "test"
  end
  
  def test_show
    get :show, :id => @block.id, :format => "html"

    assert_response :success
    log @response.body
    assert_select "div.content", "I worked."
    assert_select "a.disabled span", "Publish"
    assert_select ".block_published_status", "published"
  end
  
  def test_show_draft
    @block.update_attributes(:content => "Something Different")
    
    get :show, :id => @block.id, :format => "html"

    assert_response :success
    log @response.body
    assert_select "div.content", "Something Different"
    assert_select "a.disabled span", :text => "Publish", :count => 0
    assert_select "a.button span", :text => "Publish", :count => 1    
    assert_select ".block_published_status", "draft"
  end
  
  def test_creating_a_block_that_should_be_connected_to_a_page
    @page = Factory(:page, :path => "/test", :section => root_section)
    html_block_count = HtmlBlock.count

    post :create, :html_block => Factory.attributes_for(:html_block).merge(
      :connect_to_page_id => @page.id, :connect_to_container => "test")
      
    assert_incremented html_block_count, HtmlBlock.count
    assert_equal "test", @page.reload.connectors.first.container
    assert_redirected_to @page.path
  end  
  
  def test_index
    get :index
    assert_response :success
    assert_select "td", "Test"
    assert_select "td.block_status"  do
      assert_select "img[alt=?]", "Published"
    end
  end
  
  def test_search
    get :index, :search => {:term => 'test'}
    assert_response :success
    assert_select "td", "Test"

    get :index, :search => {:term => 'worked', :include_body => true }
    assert_response :success
    assert_select "td", "Test"

    get :index, :search => {:term => 'invalid'}
    assert_response :success
    assert_select "td", {:count=>0, :text=>"Test"}
  end
  
  def test_edit
    get :edit, :id => @block.id
    assert_response :success
    assert_select "input[id=?][value=?]", "html_block_name", "Test"
  end  
  
  
  def test_update
    html_block_count = HtmlBlock.count
    html_block_version_count = HtmlBlock::Version.count
    
    put :update, :id => @block.id, :html_block => {:name => "Test V2"}
    reset(:block)

    assert_redirected_to [:cms, @block]
    assert_equal html_block_count, HtmlBlock.count
    assert_incremented html_block_version_count, HtmlBlock::Version.count
    assert_equal "Test V2",  @block.draft.name
    assert_equal "Html Block 'Test V2' was updated", flash[:notice]
  end
    
  def test_publish
    @block.update_attributes(:content => "Something Different")
    
    assert !@block.live?

    put :publish, :id => @block.id
    reset(:block)

    assert_redirected_to [:cms, @block]
    assert @block.reload.live?
  end  
  
  def test_versions
    get :versions, :id => @block.id
    assert_response :success
    assert_equal @block, assigns(:block)
  end  
  
  def test_revert_to
    @block.update_attributes(:name => "Test V2")
    reset(:block)
    
    put :revert_to, :id => @block.id, :version => "1"
    reset(:block)
    
    assert_equal 3, @block.draft.version
    assert_equal "Test", @block.reload.name
    assert_equal "Html Block 'Test' was reverted to version 1", flash[:notice]
    assert_redirected_to [:cms, @block]
  end
  
  def test_revert_to_with_invalid_version_parameter
    @block.update_attributes(:name => "Test V2", :publish_on_save => true)
    reset(:block)

    html_block_version_count = HtmlBlock::Version.count
    
    put :revert_to, :id => @block.id, :version => 99
    reset(:block)
    
    assert_equal html_block_version_count, HtmlBlock::Version.count
    assert_equal "Html Block 'Test V2' could not be reverted to version 99", flash[:error]
    assert_redirected_to [:cms, @block]
  end
  
  def test_usages
    @page = Factory(:page, :section => root_section, :name => "Included")
    @page2 = Factory(:page, :section => root_section, :path => "/other_path", :name => "Excluded")
    @block = Factory(:html_block, :connect_to_page_id => @page.id, :connect_to_container => "main")
    
    get :usages, :id => @block.id

    assert_response :success
    assert_select "h1", "Pages Using Text '#{@block.name}'"
    assert_select "td.page_name", "Included"
    assert_select "td.page_name", {:count => 0, :text => "Excluded"}
    assert_select "h3", "Content Types"
  end
  
end