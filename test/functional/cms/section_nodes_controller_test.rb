require 'test_helper'

module Cms

class SectionNodesControllerPermissionsTest < ActionController::TestCase
  tests Cms::SectionNodesController
  include Cms::ControllerTestHelper
  
  def setup
    # DRYME copypaste from UserPermissionTest
    @user = Factory(:user)
    login_as(@user)
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    @group.permissions << create_or_find_permission_named("edit_content")
    @group.permissions << create_or_find_permission_named("publish_content")
    @user.groups << @group
    
    @editable_section = Factory(:section, :parent => root_section, :name => "Editable")
    @group.sections << @editable_section
    @editable_page = Factory(:page, :section => @editable_section, :name => "Editable Page")
    @editable_link = Factory(:link, :section => @editable_section, :name => "Editable Link")
    
    @noneditable_section = Factory(:section, :parent => root_section, :name => "Not Editable")
    @noneditable_page = Factory(:page, :section => @noneditable_section, :name => "Non-Editable Page")
    @noneditable_link = Factory(:link, :section => @noneditable_section, :name => "Non-Editable Link")
    
    @noneditables = [@noneditable_section, @noneditable_page, @noneditable_link]
    @editables = [@editable_section,
      @editable_page, 
      @editable_link,]
  end
  
  def test_index_as_contributor_with_subsections
    get :index
    assert_response :success
    
    # Check that each non-editable has the non-editable class, and that each editable does not have
    # the non-editable class
    @noneditables.each do |ne|
      assert_select "td.node.non-editable div", ne.name
    end
    @editables.each do |e|
      td = css_select("td##{e.class.to_s.demodulize.underscore}_#{e.id}", e.name).first
      assert !td.attributes["class"].include?("non-editable")
    end
  end
end

end
