require "test_helper"

class EngineConfigurationTest < ActiveSupport::TestCase

  test "site_domain" do
    assert_equal "localhost:3000", Rails.configuration.cms.site_domain
  end
end