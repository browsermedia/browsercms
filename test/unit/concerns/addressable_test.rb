require "minitest_helper"

class WannabeAddressable
  extend Cms::Concerns::CanBeAddressable
end

class CouldBeAddressable < ActiveRecord::Base

end

describe Cms::Concerns::Addressable do
  describe '#is_addressable' do
    it "should have parent relationship" do
      WannabeAddressable.expects(:attr_accessible).with(:parent)
      WannabeAddressable.expects(:has_one)
      WannabeAddressable.is_addressable
      WannabeAddressable.new.must_respond_to :parent
    end

    it "should be added to all ActiveRecord classes" do
      CouldBeAddressable.must_respond_to :is_addressable
    end
  end
end
