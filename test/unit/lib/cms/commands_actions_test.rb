require "test_helper"

require 'cms/commands/actions'

class MyTest < ActiveSupport::TestCase

  def self.source_root(path)
    # Noop - Needed to make tests work
  end
  include Cms::Commands::Actions

  test "#module_name with singular class name" do
    @project_name = "hello"

    assert_equal "Hello", module_class
  end

  test "#module_name with plural class name" do
      @project_name = "bcms_widgets"

      assert_equal "BcmsWidgets", module_class
    end
end