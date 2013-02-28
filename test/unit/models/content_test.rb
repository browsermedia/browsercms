require "minitest_helper"

describe Cms::Content do

  describe ".find" do
    let(:expected_block) do
      create(:content_type, name: "Cms::HtmlBlock")
      create(:html_block)
    end

    let(:expected_page) { create(:page)  }
    it "should find blocks by content_name" do
      found = Cms::Content.find("html_block", expected_block.id)
      found.must_equal expected_block
    end

    it "should find pages" do
      found = Cms::Content.find("page", expected_page.id)
      found.must_equal expected_page
    end
  end
end
