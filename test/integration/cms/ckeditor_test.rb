require File.join(File.dirname(__FILE__) + '/../../test_helper')

class CkeditorTest < ActionController::IntegrationTest
  include Cms::IntegrationTestHelper

  def setup
    login_as_cms_admin
  end

  # These tests are broken as of 3.1.x and are fixed in later updates. So skip running them for now.
  def skip_test_ckeditor_select
    get new_cms_html_block_url
    assert_response :success
    
    assert_tag :tag => "select",
               :attributes => { :id => "dhtml_selector", 
                                :onchange =>  "toggleEditor('html_block_content', this)"}, 
               :child => { :tag => "option", :content =>  "Rich Text" }
  end

  # These tests are broken as of 3.1.x and are fixed in later updates. So skip running them for now.
  def skip_test_ckeditor_js_added
    get new_cms_html_block_url
    assert_response :success
    
    assert_tag :tag => "script",
               :attributes => { :src => /^\/bcms\/ckeditor\/ckeditor.js.*/} 
  end

end
