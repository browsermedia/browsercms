require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::ImageBlocksControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper

  def setup
    login_as_cms_admin
  end
  
  def test_new
    get :new
    assert_response :success
    assert_select "title", "Content Library / Add New Image"
  end
  
  def test_edit
    @image = Factory(:image_block, 
      :attachment_section => root_section, 
      :attachment_file => mock_file, 
      :attachment_file_path => "test.jpg")
    
    get :edit, :id => @image.id
  
    assert_response :success
    assert_equal root_section.id, assigns(:block).attachment_section_id
    assert_select "title", "Content Library / Edit Image"
    assert_select "h1", "Edit Image '#{@image.name}'"
    assert_select "select[name=?]", "image_block[attachment_section_id]" do
      assert_select "option[value=?][selected=?]", root_section.id, "selected"
    end
  end
  
  def test_update_image
    @image = Factory(:image_block, 
      :attachment_section => root_section, 
      :attachment_file => mock_file, 
      :attachment_file_path => "test.jpg")
    @other_section = Factory(:section, :parent => root_section, :name => "Other")
    
    put :update, :id => @image.id, :image_block => {:attachment_section_id => @other_section.id}
    reset(:image)

    assert_redirected_to [:cms, @image]
    assert_equal @other_section, @image.attachment_section
  end  
  
  def test_revert_to
    @image = Factory(:image_block, 
      :attachment_section => root_section,
      :attachment_file => mock_file(:read => "11111"), 
      :attachment_file_path => "test.jpg",
      :publish_on_save => true)
    @image.update_attributes(:attachment_file => mock_file(:read => "22222"), :publish_on_save => true)
    reset(:image)

    assert @image.live?    
    assert_equal 2, @image.version
    assert_equal 2, @image.attachment_version
    assert_equal "22222", File.read(@image.attachment.full_file_location)
    
    put :revert_to, :id => @image.id, :version => "1"
    reset(:image)
    
    assert_redirected_to [:cms, @image]
    assert !@image.live?    
    @draft_image = @image.as_of_draft_version
    assert_equal 2, @image.version
    assert_equal 2, @image.attachment_version
    assert_equal 3, @draft_image.version
    assert_equal 3, @draft_image.attachment_version
    assert_equal "22222", File.read(@image.attachment.full_file_location)
    assert_equal "11111", File.read(@draft_image.attachment.full_file_location)
  end
  
end