require "minitest_helper"

describe Cms::UserPresenter do
  describe '#logged_in?' do
    it "should be false for guests" do
      Cms::UserPresenter.new(Cms::GuestUser.new).logged_in?.must_equal false
    end
  end
end
