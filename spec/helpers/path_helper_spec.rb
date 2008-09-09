require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cms::PathHelper do

  describe "path generation" do
    before do
      @block = new_html_block
      @block.id = 7
    end
    {
                                    "'blocks'" => "/cms/blocks",
                                   "'/blocks'" => "/cms/blocks",
                                     ":blocks" => "/cms/blocks",
              ":blocks, :type => 'html_block'" => "/cms/blocks?type=html_block",
             "'blocks', :type => 'html_block'" => "/cms/blocks?type=html_block",
            "'/blocks', :type => 'html_block'" => "/cms/blocks?type=html_block",
                              "'blocks', :new" => "/cms/blocks/new",
                             "'/blocks', :new" => "/cms/blocks/new",
                               ":blocks, :new" => "/cms/blocks/new",
        ":blocks, :new, :type => 'html_block'" => "/cms/blocks/new?type=html_block",
       "'blocks', :new, :type => 'html_block'" => "/cms/blocks/new?type=html_block",
      "'/blocks', :new, :type => 'html_block'" => "/cms/blocks/new?type=html_block",
                                      "@block" => "/cms/html_blocks/show/7",
                     "'html_blocks', :id => 7" => "/cms/html_blocks?id=7",
                    "'/html_blocks', :id => 7" => "/cms/html_blocks?id=7",
                      ":html_blocks, :id => 7" => "/cms/html_blocks?id=7",
                            "'html_blocks', 7" => "/cms/html_blocks/7",
                         "'/html_blocks', '7'" => "/cms/html_blocks/7",
                               "@block, :edit" => "/cms/html_blocks/edit/7",
              "'html_blocks', :edit, :id => 7" => "/cms/html_blocks/edit?id=7",
             "'/html_blocks', :edit, :id => 7" => "/cms/html_blocks/edit?id=7",
               ":html_blocks, :edit, :id => 7" => "/cms/html_blocks/edit?id=7",
                     "'html_blocks', :edit, 7" => "/cms/html_blocks/edit/7",
                  "'/html_blocks', :edit, '7'" => "/cms/html_blocks/edit/7",
                "@block, :edit, :foo => 'bar'" => "/cms/html_blocks/edit/7?foo=bar",
                      ":blocks, :edit, @block" => "/cms/blocks/edit/7",
       ":blocks, :edit, @block, :foo => 'bar'" => "/cms/blocks/edit/7?foo=bar",
              "'somewhere', :msg => 'foo bar'" => "/cms/somewhere?msg=foo+bar",
              "'somewhere', :block_id => @block" => "/cms/somewhere?block_id=7"
      #TODO: Some possible enhancements
      #"'/foo?x=1', :x => 2, :y => 3" => "/cms/foo?x=2&y=3"
       
    }.each do |args, path|
      it "cms_path(#{args}) should == '#{path}'" do
        eval("helper.send(:cms_path, #{args})").should == path
      end
    end
    
    it "should be able to generate fully qualified urls" do
      helper.cms_url('/foo').should == 'http://test.host/cms/foo'
    end
  end 
  
end