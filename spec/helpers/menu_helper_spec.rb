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
      # @desired_output.should have_tag("div.menu") do |menu|
      #   menu.first.should have_tag("li#section_#{@afc.id}") do |afc|
      #     afc.first.attributes["class"].should == "first open"
      #   end
      # end
    end
  end
  
end