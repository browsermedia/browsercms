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

  it "should create a new instance of its class via new_content with no params" do
    @b = @c.new_content
    @b.class.should == HtmlBlock
  end

  it "should create a new instance with params" do
    @b = @c.new_content(:name => "Test")
    @b.name.should == "Test"
  end

  it "should return the standard view for new" do
    @c.template_for_new.should == "cms/blocks/new"
  end

  it "should return custom new if model class overrides it" do
    content_type = ContentType.new({:name => "Portlet"})
    content_type.template_for_new.should == "cms/portlets/select_portlet_type"
  end

  it "should raise exception if no block was registered of that type" do
    @find = lambda{ ContentType.find_by_key("non_existant_type") }
    @find.should raise_error
  end
end