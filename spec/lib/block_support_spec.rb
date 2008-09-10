require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cms::BlockSupport do
  it "should respond to content_block_type? for path generation" do
    HtmlBlock.new.should respond_to(:content_block_type)
  end
  

end