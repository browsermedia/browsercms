require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HtmlBlock do
  it "should render it's content" do
    @html_block = create_html_block
    @html_block.render.should == @html_block.content
  end
end
