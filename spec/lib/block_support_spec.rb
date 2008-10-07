require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cms::BlockSupport do

  before do
    class MockBlock
      stub!(:after_create => true)
      include Cms::BlockSupport
    end    
  end

  describe "a page with multiple versions connected to the same block" do
    before do
      @page = create_page({ :name => "v1", :section => root_section })
      @block = create_html_block
      @page.add_content_block!(@block, "foo")
      @page.update_attributes!(:name => "v2")
    end
    it "should be able to get a distinct set of pages" do
      @block.connected_pages.all(:order => "name").should == [@page]
    end
    it "should have one page" do
      @block.connected_pages.count.should == 1
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

end