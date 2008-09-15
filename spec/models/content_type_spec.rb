require File.dirname(__FILE__) + '/../spec_helper'

describe ContentType do
  before do
    @c = ContentType.new({:name => "HtmlBlock"})
  end

  it "should correctly convert name to classes" do
    @c.name.should == "HtmlBlock"
    @c.name.classify.should == "HtmlBlock"
    @c.name.classify.constantize.should == HtmlBlock
  end

  it "should have model_class method" do
    @c.model_class.should == HtmlBlock
  end
  
  it "should have display_name that shows renderable name from class" do
    @c.display_name.should == "Html"
  end

  it "should have plural display_name" do
    @c.display_name_plural.should == "Html"
  end

  it "should have content_block_type to help build urls" do
    @c.content_block_type.should == "html_blocks"
  end
end