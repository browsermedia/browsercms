require "test_helper"
require 'mocha'

class ProtectedController < ActionController::Base
  include Cms::Authentication::Controller
end

class ControllerTest < ActiveSupport::TestCase

  test "Sets current user in thread local" do
    u = Cms::User.new()

    c = ProtectedController.new
    c.expects(:session).returns({})

    c.send(:cms_current_user=, u)

    assert_equal u, Cms::User.current
  end
end