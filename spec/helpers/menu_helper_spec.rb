require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cms::MenuHelper do

  describe "render_menu" do
    before do
      #/                    (Section)
      #/fruits/             (Section)
      @fruits = create_section(:parent => root_section, :name => "Fruits", :path => "/fruits")
      # /fruits/overview     (Page)
      @overview = create_page(:section => @fruits, :name => "Overview", :path => "/fruits/overview")
      # /fruits/red/         (Section)
      @red = create_section(:parent => @fruits, :name => "Red", :path => "/fruits/red")
      # /fruits/red/apples   (Page)
      @apples = create_page(:section => @red, :name => "Apples", :path => "/fruits/red/apples")      
      # /fruits/red/grapes   (Page)
      @apples = create_page(:section => @red, :name => "Grapes", :path => "/fruits/red/grapes")
      # /fruits/bananas      (Page)
      @apples = create_page(:section => @fruits, :name => "Bananas", :path => "/fruits/bananas")
      # /veggies/            (Section)
      @veggies = create_section(:parent => root_section, :name => "Veggies", :path => "/veggies")
      # /veggies/spinach     (Page)
      @spinach = create_page(:section => @veggies, :name => "Spinach", :path => "/veggies/spinach")
      # /veggies/carrots     (Page)
      @spinach = create_page(:section => @veggies, :name => "Carrots", :path => "/veggies/carrots")
      log Section.to_table_with(:id, :name, :path, :root)
      log Page.to_table_with(:id, :name, :path)
      log SectionNode.to_table_without(:created_at, :updated_at)
      assigns[:page] = @apples
    end
    it "should render the menu" do
      pending "Case 1508"
      html = <<-HTML
<div class="leftnav">
  <ul>
    <li><a class="open" href="/fruits/overview">Fruits</a></li>
       <ul>
          <li><a class="open" href="/fruits/red/apples">Red</a></li>
             <ul>
                <li><a class="on" href="/fruits/apples">Apples</a></li>
            </ul>
            <li><a href="/fruits/bananas">Bananas</a></li>
       </ul>           
    <li><a href="/fruits/veggies">Veggies</a></li>
  </ul>
</div>      
      HTML
      helper.render_menu.should == html
    end
  end
  
end