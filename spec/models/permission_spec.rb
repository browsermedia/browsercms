require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Permission do
  it "should validate uniqueness of name" do
    create_permission(:name => "unique")
    permission = new_permission(:name => "unique")
    permission.should_not be_valid
    permission.should have(1).error_on(:name)
  end
end
