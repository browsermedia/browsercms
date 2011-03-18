require "test_helper"

class DatePickerTest < ActiveSupport::TestCase

  test "DatePicker Formatting" do
    assert_equal "yy/mm/dd", Cms::DatePicker.jquery_format
  end

  test "Formats date for UI output" do
    date = DateTime.new(2011, 3, 14)
    assert_equal "2011/03/14", Cms::DatePicker.format_for_ui(date)
  end

  test "Formatting of nil dates" do
    assert_nil(Cms::DatePicker.format_for_ui(nil))
  end
end