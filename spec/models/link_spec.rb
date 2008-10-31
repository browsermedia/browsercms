require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Link do
  
  describe "creating a link" do
    it "should be successful" do
      create_link.should be_valid
    end
    
    it "should be unsuccessful with bad url" do
      new_link(:url => "bad url").should_not be_valid
    end
    
    it "should be unsuccessful with no name given" do
      new_link(:name => "").should_not be_valid
    end
  end
  
  describe "versioning for links" do
    it "should support versioning" do
      h = Link.new
      h.versionable?.should be_true
    end

    describe "when creating a record" do
      before do
        @link = create_link
      end
      it "should create a version when creating a link" do
        @link.versions.latest.link.should == @link
      end
    end

    describe "when updating attributes" do
      describe "with different values" do
        before do
          @link = create_link(:name => "Original Value")
          @link.update_attributes(:name => "Something Different")
        end
        it "should create a version with the changed values" do
          @link.versions.latest.link.should == @link
          @link.versions.latest.name.should == "Something Different"
          @link.name.should == "Something Different"
        end
        it "should not affect the values in previous versions" do
          @link.versions.first.name.should == "Original Value"
        end
      end      
      describe "with the unchanged values" do
        before do
          @link = create_link(:name => "Original Value")
          @update_attributes = lambda { @link.update_attributes(:name => "Original Value") }
        end
        it "should not create a new version" do
          @update_attributes.should_not change(@link.versions, :count)
        end
      end
    end

    describe "when deleting a record" do
      before do
        @link = create_link
        @delete_link = lambda { @link.mark_as_deleted!(create_user) }
      end
      
      it "should not actually delete the row" do
        @delete_link.should_not change(Link, :count_with_deleted)
      end
      it "should create a new version" do
        @delete_link.should change(@link.versions, :count).by(1)
      end
      it "should set the status to DELETED" do
        @delete_link.call
        @link.should be_deleted
      end
    end
    
    describe "when getting previous version of a link" do
      before do
        @link = create_link(:name => "V1")
        @link.update_attributes(:name => "V2")
        @version = @link.as_of_version 1
      end
      it "should return an Link, rather than an Link::Version" do
        @version.class.should == Link
      end
      it "should have the name set to the name of the older version" do
        @version.name.should == "V1"
      end
      it "should have the version set to the version of the older version" do
        @version.version.should == 1
      end
      it "should have the same id" do
        @version.id.should == @link.id
      end
      it "should not be frozen" do
        #We can't freeze the version because we need to be able to load assocations
        @version.should_not be_frozen
      end
      it "current_version? should be false" do
        @version.current_version?.should be_false
      end
      it "current_version? should be true for the original object" do
        @link.current_version?.should be_true
      end
    end
  end

end
