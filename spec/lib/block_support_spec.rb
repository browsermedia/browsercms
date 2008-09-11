require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cms::BlockSupport do

  before do
    # Note: I'm unhappy about mocking out this block this way, but I couldn't figure out how to split ActiveRecord as
    # well as BlockSupport. Mainly, the need to instansiate an instance of this mock block caused me problems.
    #
    # The only thing this spec should be testing is BlockSupport.
    class MockBlock
      def self.after_create (ignored)
        # do nothing to mock ActiveRecord
      end
      include Cms::BlockSupport
    end
  end
  
  it "should respond to content_block_type? for path generation" do
    HtmlBlock.new.should respond_to(:content_block_type)
  end

  it "should use display_name as content_block_label by default" do
    MockBlock.display_name.should == "Mock Block"
    MockBlock.display_name_plural.should == "Mock Blocks"
    MockBlock.display_name.should == MockBlock.content_block_label
  end
  
  it "should have label on class which describes human readable class name" do
    HtmlBlock.content_block_label.should == "Html Block"
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