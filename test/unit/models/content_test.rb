require "minitest_helper"

describe Cms::Content do

  let(:expected_block) { create(:html_block) }

  describe ".find" do
    let(:expected_page) { create(:page) }

    it "should find blocks by content_name" do
      found = Cms::Content.find("html_block", expected_block.id)
      found.must_equal expected_block
    end

    it "should find pages" do
      found = Cms::Content.find("page", expected_page.id)
      found.must_equal expected_page
    end
  end

  describe '.find_draft' do
    it "should find the latest version of a block" do
      expected_block.update_attributes(:name => "Version 2")
      found = Cms::Content.find_draft("html_block", expected_block.id)
      found.version.must_equal 2
    end
  end
end

