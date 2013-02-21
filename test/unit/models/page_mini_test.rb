require "minitest_helper"

describe Cms::Page do

  describe ".find_draft" do

    let(:page) { create(:page) }

    it "should return the latest draft of the page" do
      page.name = "Version 2"
      page.save

      found = Cms::Page.find_draft(page.id)
      found.must_be_instance_of Cms::Page
      found.name.must_equal page.name
    end
  end
end
