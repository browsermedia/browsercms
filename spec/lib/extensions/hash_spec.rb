require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Hash do
  describe "#except" do
    it "should return a new hash without the specified keys" do
      x = {:a => 1, :b => 2}
      x.except(:a).should == {:b => 2}
      x.should == {:a => 1, :b => 2}
    end
  end
end