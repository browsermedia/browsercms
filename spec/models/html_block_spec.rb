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
  
  describe "versioning for blocks" do
    describe "when creating a record" do
      before do
        @html_block = create_html_block
      end
      it "should create a version when creating a html_block" do
        @html_block.versions.latest.html_block.should == @html_block
      end
    end
    
    describe "when updating attributes" do
      describe "with different values" do
        before do
          @html_block = create_html_block(:name => "Original Value")
          @html_block.update_attributes(:name => "Something Different")
        end
        it "should create a version with the changed values" do
          @html_block.versions.latest.html_block.should == @html_block
          @html_block.versions.latest.name.should == "Something Different"
          @html_block.name.should == "Something Different"
        end
        it "should not affect the values in previous versions" do
          @html_block.versions.first.name.should == "Original Value"
        end
      end      
      describe "with the unchanged values" do
        before do
          @html_block = create_html_block(:name => "Original Value")
          @update_attributes = lambda { @html_block.update_attributes(:name => "Original Value") }
        end
        it "should not create a new version" do
          @update_attributes.should_not change(@html_block.versions, :count)
        end
      end
    end
    
    describe "when deleting a record" do
      before do
        @html_block = create_html_block
        @delete_html_block = lambda { @html_block.delete! }
      end
      
      it "should not actually delete the row" do
        @delete_html_block.should_not change(HtmlBlock, :count)
      end
      it "should create a new version" do
        @delete_html_block.should change(@html_block.versions, :count).by(1)
      end
      it "should set the status to DELETED" do
        @delete_html_block.call
        @html_block.should be_deleted
      end
    end    
    
    describe "when reverting an existing block" do
      before do
        @html_block = new_html_block(:name => "Version One")
        @v1_created_at = Time.zone.now - 5.days
        @html_block.created_at = @v1_created_at
        @html_block.save
        v1 = @html_block.versions.latest
        v1.created_at = @v1_created_at
        v1.save
        @html_block.update_attributes(:name => "Version Two")
        @v2_created_at = @html_block.versions.latest.created_at
      end
      it "should be able to revert" do
        @html_block.name.should == "Version Two"
        @html_block.revert(1)
        @html_block.reload.version.should == 3
        @html_block.name.should == "Version One" 
      end
      it "should keep the original created at time" do        
        @html_block.find_version(1).created_at.to_i.should == @v1_created_at.to_i
        @html_block.find_version(2).created_at.to_i.should == @v2_created_at.to_i
        @html_block.revert(1)
        @html_block.reload
        @html_block.find_version(1).created_at.to_i.should == @v1_created_at.to_i
        @html_block.find_version(2).created_at.to_i.should == @v2_created_at.to_i
        @html_block.find_version(3).created_at.to_i.should >= @v2_created_at.to_i
        @html_block.created_at.to_i.should == @v1_created_at.to_i        
      end
    end
  end
  
end
