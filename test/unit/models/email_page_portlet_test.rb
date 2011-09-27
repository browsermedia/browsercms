require 'test_helper'

class EmailPagePortletTest < ActiveSupport::TestCase

  def test_default_template_path
    assert_equal "portlets/email_page/render", EmailPagePortlet.default_template_path
  end

  def test_default_template
    assert_equal File.read(File.expand_path(File.join(engine_root_dir, "app/views/portlets/email_page/render.html.erb"))), EmailPagePortlet.default_template
  end

  private

  # Rails.root won't work, since that's the dummy app. So find the root director of this project.
  def engine_root_dir
    File.join(__FILE__, "..", "..", "..", "..")
  end
end

