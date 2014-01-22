require "minitest_helper"

describe "ContentApi" do

  let(:html_block){ Cms::HtmlBlock.new }

  describe '#content_name' do
    it "should generate a readable key" do
      html_block.content_name.must_equal "html_block"
    end

    it "should properly namespace non-core blocks" do
      Dummy::Product.new.content_name.must_equal "dummy/product"
    end
  end


end
