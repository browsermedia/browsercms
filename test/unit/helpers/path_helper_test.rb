require File.join(File.dirname(__FILE__), '/../../test_helper')

class Cms::PathHelperTest < ActionView::TestCase
  
  def test_path_generation_
    @new_block = Factory.build(:html_block)
    @existing_block = Factory(:html_block, :id => 7)

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
   
                # First value = controller, 2nd = actions, 3rd = id
                ":blocks, :edit, @existing_block" => "/cms/blocks/edit/7",
                ":blocks, :show, @existing_block" => "/cms/blocks/show/7",
                ":blocks, :edit, @existing_block, :foo => 'bar'" => "/cms/blocks/edit/7?foo=bar",
                          
                        "@existing_block, :edit" => "/cms/blocks/html_block/edit/7",
         "@existing_block, :edit, :foo => 'bar'" => "/cms/blocks/html_block/edit/7?foo=bar",
                 "@new_block, :create_or_update" => "/cms/blocks/html_block/create",
            "@existing_block, :create_or_update" => "/cms/blocks/html_block/update/7",                
                               "@existing_block" => "/cms/blocks/html_block/show/7",
               
     "'somewhere', :block_id => @existing_block" => "/cms/somewhere?block_id=7"
      #TODO: Some possible enhancements
      #"'/foo?x=1', :x => 2, :y => 3" => "/cms/foo?x=2&y=3"
       
    }.each do |args, path|
      assert_equal path, eval("cms_path(#{args})")
    end
    
  end 
  
end