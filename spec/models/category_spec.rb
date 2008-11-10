require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Category do
  it "should be able to create a category" do
    lambda { create_category }.should_not raise_error
  end
end
