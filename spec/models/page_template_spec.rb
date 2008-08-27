require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PageTemplate do
  it "should create a new instance given valid attributes" do
    PageTemplate.create!(new_page_template.attributes)
  end
end
