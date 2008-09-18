require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cms::PathHelper do

  describe "path generation" do
    before do
      @new_block = mock("html_block", :new_record? => true, :class => HtmlBlock, :content_block_type => 'html')
      @existing_block = mock("html_block", :new_record? => false, :to_param => 7, :class => HtmlBlock, :content_block_type => 'html') 
      @page_template = mock("page_template", :to_param => 7, :class => PageTemplate)     
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
                       "'html_blocks', :id => 7" => "/cms/html_blocks?id=7",
                      "'/html_blocks', :id => 7" => "/cms/html_blocks?id=7",
                        ":html_blocks, :id => 7" => "/cms/html_blocks?id=7",
                              "'html_blocks', 7" => "/cms/html_blocks/7",
                           "'/html_blocks', '7'" => "/cms/html_blocks/7",
                "'html_blocks', :edit, :id => 7" => "/cms/html_blocks/edit?id=7",
               "'/html_blocks', :edit, :id => 7" => "/cms/html_blocks/edit?id=7",
                 ":html_blocks, :edit, :id => 7" => "/cms/html_blocks/edit?id=7",
                       "'html_blocks', :edit, 7" => "/cms/html_blocks/edit/7",
                    "'/html_blocks', :edit, '7'" => "/cms/html_blocks/edit/7",
                "'somewhere', :msg => 'foo bar'" => "/cms/somewhere?msg=foo+bar",
   
                #Non block objects
                                "@page_template" => "/cms/page_templates/show/7",
                         "@page_template, :edit" => "/cms/page_templates/edit/7",                
                
                # First value = controller, 2nd = actions, 3rd = id
                ":blocks, :edit, @existing_block" => "/cms/blocks/edit/7",
                ":blocks, :show, @existing_block" => "/cms/blocks/show/7",
                ":blocks, :edit, @existing_block, :foo => 'bar'" => "/cms/blocks/edit/7?foo=bar",
                          
                        "@existing_block, :edit" => "/cms/blocks/html/edit/7",
         "@existing_block, :edit, :foo => 'bar'" => "/cms/blocks/html/edit/7?foo=bar",
                 "@new_block, :create_or_update" => "/cms/blocks/html/create",
            "@existing_block, :create_or_update" => "/cms/blocks/html/update/7",                
                               "@existing_block" => "/cms/blocks/html/show/7",
               
     "'somewhere', :block_id => @existing_block" => "/cms/somewhere?block_id=7"
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