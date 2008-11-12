require File.dirname(__FILE__) + '/../spec_helper'

describe ContentType do
  before do
    @c = ContentType.new({:name => "HtmlBlock"})
  end

  it "should correctly convert name to classes" do
    @c.name.should == "HtmlBlock"
    @c.name.classify.should == "HtmlBlock"
    @c.name.classify.constantize.should == HtmlBlock
  end

  it "should have model_class method" do
    @c.model_class.should == HtmlBlock
  end

  it "should have display_name that shows renderable name from class" do
    @c.display_name.should == "Text"
  end

  it "should have plural display_name" do
    @c.display_name_plural.should == "Text"
  end

  it "should have content_block_type to help build urls" do
    @c.content_block_type.should == "html_blocks"
  end

  describe "templates to render CRUD actions" do
    describe "with core blocks (no overrides)" do
      it "should return the standard view for :new" do
        @c.template_for_new.should == "cms/blocks/new"
      end

      it "should return basic edit for :edit" do
        @c.template_for_edit.should == "cms/blocks/edit"
      end
      it "should not add any extra columns" do
        cols = @c.columns_for_index
        cols.size.should == 0
      end
    end
    describe "with blocks that override template methods" do
      before(:each) do
        class MyModel
          def self.template_for_new
            "cms/my_models/special_view"
          end
          def self.template_for_edit
            "cms/my_models/special_edit"
          end

          def self.columns_for_index
            ["stuff", {:label =>"More Stuff", :method => "more"}]
          end
        end
        @content_type = ContentType.new({:name => "MyModel"})
      end
      it "should return custom new" do
        @content_type.template_for_new.should == "cms/my_models/special_view"
      end
      it "should return custom edit" do
        @content_type.template_for_edit.should == "cms/my_models/special_edit"
      end
      it "should add additional columns to the view" do
        cols = @content_type.columns_for_index
        cols.size.should == 2
        cols.should == [{:label => "Stuff", :method => "stuff"}, {:label => "More Stuff", :method => "more"}]
      end
    end




  end
end