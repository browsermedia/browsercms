require 'test_helper'

class CkeditorTest < ActionController::IntegrationTest
  include Cms::IntegrationTestHelper

  def setup
    login_as_cms_admin
  end

  def test_ckeditor_select
    get new_cms_html_block_url
    assert_response :success
    
    assert_tag :tag => "select",
               :attributes => { :id => "dhtml_selector", 
                                :onchange =>  "toggleEditor('cms_html_block_content', this)"}, 
               :child => { :tag => "option", :content =>  "Rich Text" }
  end

end
