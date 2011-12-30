require "test_helper"
require 'cms/installation_actions'

module BcmsWidget
end

class InstallGeneratorTest < ActiveSupport::TestCase

  include Cms::InstallationActions

  test "generate default name" do
    assert_equal "/bcms_widget", default_engine_path(BcmsWidget)
  end

end