require "test_helper"

module Dummy
  class DeprecatedInputTest < ActiveSupport::TestCase

    test "#model_form_name should use full model name" do
      assert_equal "dummy_deprecated_input", DeprecatedInput.content_type.param_key
    end
  end
end
