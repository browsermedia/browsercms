require File.join(File.dirname(__FILE__), '/../../test_helper')

class EmailPagePortletTest < ActiveSupport::TestCase

  def test_default_template_path
    assert_equal "portlets/email_page/render", EmailPagePortlet.default_template_path
  end

  def test_default_template
    assert_equal File.read(File.join(Rails.root, "app/views/portlets/email_page/render.html.erb")), EmailPagePortlet.default_template
  end

end

