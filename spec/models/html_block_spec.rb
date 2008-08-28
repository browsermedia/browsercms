require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HtmlBlock do
  it "should render it's content" do
    @html_block = create_html_block
    @html_block.render.should == @html_block.content
  end
  
  it "should be able to be connected to a page" do
    @page = create_page
    lambda do
      @html_block = create_html_block(:connect_to_page_id => @page.id, :connect_to_container => "test")
    end.should change(@page.connectors, :count).by(1)
    @html_block.connected_page.should == @page
  end
  
end
