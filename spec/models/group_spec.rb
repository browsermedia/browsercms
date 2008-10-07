require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do
  before do
    @group = new_group
  end
  it "should be valid" do
    @group.should be_valid
  end
end
