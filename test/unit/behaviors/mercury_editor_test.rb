require 'minitest_helper'

describe "MercuryEditor" do

  describe "#editor_info" do

    let(:content_block) { Cms::HtmlBlock.new }

    it "returns full for text area fields" do
      field_info = content_block.editor_info(:content)
      field_info[:region].must_equal "full"
      field_info[:element].must_equal "div"
    end

    it "returns simple region for text fields" do
      field_info = content_block.editor_info(:name)
      field_info[:region].must_equal "simple"
      field_info[:element].must_equal "span"
    end
  end
end
