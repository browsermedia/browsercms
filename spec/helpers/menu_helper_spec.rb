require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../data/nfl')

describe Cms::MenuHelper do
  before do
    create_nfl
  end
  describe "render_menu" do
    before do
      @desired_output = <<HTML 
<div class="menu">
  <ul>
    <li id="section_#{@afc.id}" class="first open">
      <a href="/buf">AFC</a>
      <ul>
        <li id="section_#{@afc_east.id}" class="first">
          <a href="/buf">East</a>
        </li>
        <li id="section_#{@afc_north.id}" class="open">
          <a href="/bal">North</a>
          <ul>
            <li id="page_#{@bal.id}" class="first on">
              <a href="/bal">Baltimore Ravens</a>
            </li>
            <li id="page_#{@cin.id}">
              <a href="/cin">Cincinnati Bengals</a>
            </li>
            <li id="page_#{@cle.id}">
              <a href="/cle">Cleveland Browns</a>
            </li>
            <li id="page_#{@pit.id}" class="last">
              <a href="/pit">Pittsburgh Steelers</a>
            </li>
          </ul>
        </li>
        <li id="section_#{@afc_south.id}">
          <a href="/hou">South</a>
        </li>
        <li id="section_#{@afc_west.id}" class="last">
          <a href="/den">West</a>
        </li>
      </ul>
    </li>
    <li id="section_#{@nfc.id}" class="last">
      <a href="/dal">NFC</a>
    </li>
  </ul>
</div>
HTML
      assigns[:page] = @bal
    end
    it "should produce the desired output" do 
      helper.render_menu.should == @desired_output
    end
    
    it "should be able to have a custom class on the div" do
      helper.render_menu(:class => "leftnav").should have_tag("div.leftnav")
    end
    
    it "should use the first hidden page in a section" do
      @afc_east_page = create_page(:section => @afc_east, :name => "AFC East", :path => "/afc_east", :hidden => true)
      @afc_east_page.section_node.move_to(@afc_east, 0)
      helper.render_menu.should == @desired_output.gsub('/buf','/afc_east')
    end
    
    it "should not show archived pages" do
      @pit.archive(create_user)
      helper.render_menu.should_not have_tag("a[href=#{@pit.path}]")
    end
    
    it "should show the pages in the correct order" do
      @afc_west.node.move_to(@afc, 0)
      output = helper.render_menu
      output.should have_tag("li#section_#{@afc_west.id}.first")
      output.should_not have_tag("li#section_#{@afc_east.id}.first")
    end
    
  end
  describe "render_menu(:depth => 2)" do
    before do
      @desired_output = <<HTML 
<div class="menu">
  <ul>
    <li id="section_#{@afc.id}" class="first open">
      <a href="/buf">AFC</a>
      <ul>
        <li id="section_#{@afc_east.id}" class="first">
          <a href="/buf">East</a>
        </li>
        <li id="section_#{@afc_north.id}" class="open">
          <a href="/bal">North</a>
        </li>
        <li id="section_#{@afc_south.id}">
          <a href="/hou">South</a>
        </li>
        <li id="section_#{@afc_west.id}" class="last">
          <a href="/den">West</a>
        </li>
      </ul>
    </li>
    <li id="section_#{@nfc.id}" class="last">
      <a href="/dal">NFC</a>
    </li>
  </ul>
</div>
HTML
      assigns[:page] = @bal
    end

    it "should produce the desired output" do      
      helper.render_menu(:depth => 2).should == @desired_output
    end

  end  
  describe "render_menu(:from_top => 1)" do
    before do
      @desired_output = <<HTML 
<div class="menu">
  <ul>
    <li id="section_#{@afc_east.id}" class="first">
      <a href="/buf">East</a>
    </li>
    <li id="section_#{@afc_north.id}" class="open">
      <a href="/bal">North</a>
      <ul>
        <li id="page_#{@bal.id}" class="first on">
          <a href="/bal">Baltimore Ravens</a>
        </li>
        <li id="page_#{@cin.id}">
          <a href="/cin">Cincinnati Bengals</a>
        </li>
        <li id="page_#{@cle.id}">
          <a href="/cle">Cleveland Browns</a>
        </li>
        <li id="page_#{@pit.id}" class="last">
          <a href="/pit">Pittsburgh Steelers</a>
        </li>
      </ul>
    </li>
    <li id="section_#{@afc_south.id}">
      <a href="/hou">South</a>
    </li>
    <li id="section_#{@afc_west.id}" class="last">
      <a href="/den">West</a>
    </li>
  </ul>
</div>
HTML
      assigns[:page] = @bal
    end

    it "should produce the desired output" do      
      helper.render_menu(:from_top => 1, :depth => 2).should == @desired_output
    end

  end  
  describe "render_menu(:depth => 2, :show_all_siblings => true)" do
    before do
      @desired_output = <<HTML 
<div class="menu">
  <ul>
    <li id="section_#{@afc.id}" class="first open">
      <a href="/buf">AFC</a>
      <ul>
        <li id="section_#{@afc_east.id}" class="first">
          <a href="/buf">East</a>
        </li>
        <li id="section_#{@afc_north.id}" class="open">
          <a href="/bal">North</a>
        </li>
        <li id="section_#{@afc_south.id}">
          <a href="/hou">South</a>
        </li>
        <li id="section_#{@afc_west.id}" class="last">
          <a href="/den">West</a>
        </li>
      </ul>
    </li>
    <li id="section_#{@nfc.id}" class="last">
      <a href="/dal">NFC</a>
      <ul>
        <li id="section_#{@nfc_east.id}" class="first">
          <a href="/dal">East</a>
        </li>
        <li id="section_#{@nfc_north.id}">
          <a href="/chi">North</a>
        </li>
        <li id="section_#{@nfc_south.id}">
          <a href="/atl">South</a>
        </li>
        <li id="section_#{@nfc_west.id}" class="last">
          <a href="/ari">West</a>
        </li>
      </ul>
    </li>
  </ul>
</div>
HTML
      assigns[:page] = @bal
    end

    it "should produce the desired output" do 
      helper.render_menu(:depth => 2, :show_all_siblings => true).should == @desired_output
    end

  end  

end