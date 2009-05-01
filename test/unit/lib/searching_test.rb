  require File.join(File.dirname(__FILE__), '/../../test_helper')

class SearchingTest < ActiveSupport::TestCase

  def setup

  end

  def teardown

  end

  test "Searchable behavior adds search method to blocks" do
    block = HtmlBlock.create!(:name=>"Stuff")

    list = HtmlBlock.search("Stuff")

    assert_equal 1, list.size
  end

end