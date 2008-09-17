require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Cms::BlocksController do
  include Cms::PathHelper
  
  describe "#model_name" do
    describe "with no last_block_type or block_type parameter" do
      before do
        @controller.stub!(:session).and_return({})
        @controller.stub!(:params).and_return({})
      end
      it "should return 'html_block' and set the last_block_type" do
        @controller.send(:model_name).should == "html_block"
        @controller.session[:last_block_type].should == "html_block"
      end    
    end
    describe "with no last_block_type and block_type parameter of 'foo" do
      before do
        @controller.stub!(:session).and_return({})
        @controller.stub!(:params).and_return({:block_type => "foo"})
      end
      it "should return 'foo' and set the last_block_type" do
        @controller.send(:model_name).should == "foo"
        @controller.session[:last_block_type].should == "foo"
      end    
    end
    describe "with last_block_type of 'bar' and block_type parameter of 'foo'" do
      before do
        @controller.stub!(:session).and_return({:last_block_type => "bar"})
        @controller.stub!(:params).and_return({:block_type => "foo"})
      end
      it "should return 'foo' and set the last_block_type" do
        @controller.send(:model_name).should == "foo"
        @controller.session[:last_block_type].should == "foo"
      end    
    end
    describe "with last_block_type of 'bar' and no block_type parameter" do
      before do
        @controller.stub!(:session).and_return({:last_block_type => "bar"})
        @controller.stub!(:params).and_return({})
      end
      it "should return 'foo' and set the last_block_type" do
        @controller.send(:model_name).should == "bar"
        @controller.session[:last_block_type].should == "bar"
      end    
    end
  end
  
  describe "publish" do
    before do
      login_as_user
      @block = HtmlBlock.new
      @block.id = "7"
      @block.stub!(:publish).and_return(true)
      @model = mock("HtmlBlock", :find => @block)
      @controller.stub!(:model).and_return(@model)
    end
    it "should find the block" do
      @model.should_receive(:find).with("7").and_return(@block)
      post :publish, :id => "7"
    end      
    it "should be able to update the status of a block" do
      @block.should_receive(:publish).and_return(true)
      post :publish, :id => "7"
    end
    it "should redirect to the block show action" do
      post :publish, :id => "7"
      response.should redirect_to(cms_url(@block))
    end
  end
  
  describe "revert_to" do
    before do
      login_as_user
      @block = create_html_block(:name => "V1")
      @block.update_attribute(:name, "V2")
    end
    describe "with a valid version" do
      before do
        @action = lambda { post :revert_to, :id => @block, :version => "1" }
      end
      it "should create a new version of the block" do
        @action.call
        @block.reload.version.should == 3
      end
      it "should set the name of the block to the original name" do
        @action.call
        @block.reload.name.should == "V1"
      end    
      it "should set the flash message" do
        @action.call
        flash[:notice].should == "Reverted 'V1' to version 1"
      end
      it "should redirect to the block show action" do
        @action.call
        response.should redirect_to(cms_url(@block))
      end
    end
    describe "without a version parameter" do
      before do
        @action = lambda { post :revert_to, :id => @block}
      end
      it "should not create a new version of the block" do
        @action.should_not change(HtmlBlock::Version, :count)
      end
      it "should set the flash error message" do
        @action.call
        flash[:error].should == "Could not revert 'V2': Version parameter missing"
      end
      it "should redirect to the block show action" do
        @action.call
        response.should redirect_to(cms_url(@block))
      end
    end
    describe "with an invalid version parameter" do
      before do
        @action = lambda { post :revert_to, :id => @block, :version => 99}
      end
      it "should not create a new version of the block" do
        @action.should_not change(HtmlBlock::Version, :count)
      end
      it "should set the flash error message" do
        @action.call
        flash[:error].should == "Could not revert 'V2': Could not find version 99"
      end
      it "should redirect to the block show action" do
        @action.call
        response.should redirect_to(cms_url(@block))
      end
    end
  end
  
  it "should route to block controller based on block type in URL" do
    params_from(:get, '/cms/blocks/html_block/show/1').should == {:controller => 'cms/blocks', :action=>'show', :id => '1', :block_type=>'html_block'}
  end
end