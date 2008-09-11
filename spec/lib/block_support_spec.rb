require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cms::BlockSupport do

  before do
    class MockBlock
      stub!(:after_create => true)
      include Cms::BlockSupport
    end    
  end
  
  it "should respond to content_block_type? for path generation" do
    HtmlBlock.new.should respond_to(:content_block_type)
  end

  it "should use display_name as content_block_label by default" do
    MockBlock.display_name.should == "Mock Block"
    MockBlock.display_name_plural.should == "Mock Blocks"
  end
  
  it "should have overrideable display name" do
    HtmlBlock.display_name.should == "Html"
  end

  it "should make display name plural overrideable" do
    HtmlBlock.display_name_plural.should == "Html"
  end

  it "should add display_name to each block itself" do
    m = MockBlock.new
    m.display_name.should == "Mock Block"
    m.display_name_plural.should == "Mock Blocks"
  end

  it "should add overridable display_name to each block itself" do
    m = HtmlBlock.new
    m.display_name.should == "Html"
    m.display_name_plural.should == "Html"
  end

  it "should " do
    
  end
end