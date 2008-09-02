# Created by IntelliJ IDEA.
# User: Patrick Peak
# Date: Sep 2, 2008
# Time: 3:11:12 PM
# To change this template use File | Settings | File Templates.

# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe Cms::StatusSupport do

  # Called before each example.
  before(:each) do
    # Do nothing
  end

  # Called after each example.
  after(:each) do
    # Do nothing
  end

  it "should add status field to existing blocks (like HtmlBlocks)" do
    b = HtmlBlock.new
    b.save
    b.status.should == "IN_PROGRESS"
    b.status.should_not == "PUBLISHED"
  end

  it "should allow blocks to be published via 'publish' method" do
    b = HtmlBlock.new
    b.publish
    b.status.should == "PUBLISHED"

    f = HtmlBlock.find(b)
    f.status.should == "PUBLISHED"
  end
end