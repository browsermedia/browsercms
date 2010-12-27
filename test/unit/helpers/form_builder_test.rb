require_relative '../../test_helper'


silence_warnings do

  class Block
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    def persisted?
      false
    end
  end
end
class FormBuilderTest < ActionView::TestCase

  
  tests ActionView::Helpers::FormHelper


  def setup
    @block = Block.new
  end

  def teardown

  end


  test "cms_text_area with a fairly weak and semi-pointless test" do
    self.expects(:blocks_path).returns("/")
    self.expects(:protect_against_forgery?).returns(false).at_least_once

    self.expects(:render).at_least_once
    self.expects(:next_tabindex).returns({})

    form_for (@block) do |f|
      f.cms_text_area(:name)
    end
  end


end