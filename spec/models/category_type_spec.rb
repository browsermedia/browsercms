require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CategoryType do
  it "should be able to create a new category type" do
    lambda { create_category_type }.should_not raise_error
  end
end
