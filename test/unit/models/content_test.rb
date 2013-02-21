require "minitest_helper"

describe Cms::Content do

  before do
    create(:content_type, name: "Cms::HtmlBlock")
  end
  let(:expected_block) { create(:html_block) }

  it "finds content by content_name" do
    found = Cms::Content.find("html_block", expected_block.id)
    found.must_equal expected_block
  end

end
