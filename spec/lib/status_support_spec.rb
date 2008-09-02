require File.dirname(__FILE__) + '/../spec_helper'

describe Cms::StatusSupport do

  it "should add status field to existing blocks (like HtmlBlocks)" do
    b = HtmlBlock.new
    b.save
    b.reload.status.should == "IN_PROGRESS"
  end

  it "should allow blocks to be published via 'publish' method" do
    b = HtmlBlock.new
    b.publish
    b.reload.status.should == "PUBLISHED"
  end
end