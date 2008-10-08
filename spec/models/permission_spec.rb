require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Permission do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :full_name => "value for full_name",
      :description => "value for description",
      :for_module => "value for for_module"
    }
  end

  it "should create a new instance given valid attributes" do
    Permission.create!(@valid_attributes)
  end
end
