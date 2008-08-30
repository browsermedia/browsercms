require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Connector do
  it_should_validate_presence_of :container  
  it "should be able to find by block" do
    foo = create_html_block(:name => "foo")
    bar = create_html_block(:name => "bar")
    create_connector(:content_block => foo)
    blocks = Connector.for_block(foo).map(&:content_block)
    blocks.should include(foo)
    blocks.should_not include(bar)
  end

  it "should not delete blocks when deleting a connector" do
    b = create_html_block
    c = create_connector(:content_block => b)
    this_block{ c.destroy }.should change(Connector, :count).by(-1)
    HtmlBlock.find(b).should_not be_nil
  end

end
