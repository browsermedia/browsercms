require "minitest_helper"

describe "ContentApi" do

  let(:html_block){ Cms::HtmlBlock.new }

  describe '#content_name' do
    it "should generate a readable key" do
      html_block.content_name.must_equal "html_block"
    end
  end
end
