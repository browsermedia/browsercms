require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FileBlock do
  before(:each) do
    @valid_attributes = {
      :type => "value for type",
      :section_id => "1",
      :cms_file_id => "1",
      :cms_file_type => "value for cms_file_type",
      :name => "value for name"
    }
  end

  it "should create a new instance given valid attributes" do
    FileBlock.create!(@valid_attributes)
  end
end
