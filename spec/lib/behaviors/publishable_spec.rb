require File.dirname(__FILE__) + '/../../spec_helper'

ActiveRecord::Base.connection.instance_eval do
  drop_table(:publishables) if table_exists?(:publishables)
  create_table(:publishables) do |t| 
    t.string :name
    t.datetime :published_at
    t.boolean :published, :default => 0
  end
  drop_table(:unpublishables) if table_exists?(:unpublishables)
  create_table(:unpublishables) do |t| 
    t.string :name
  end
end

class Publishable < ActiveRecord::Base
  is_publishable
end

class Unpublishable < ActiveRecord::Base
end

describe "a new publishable object", :type => :model do
  before do
    @object = Publishable.new(:name => "New Record")
  end
  it "should be publishable" do
    @object.should be_publishable
  end
  describe "when saved" do
    it "should not be published" do
      @object.save
      @object.should_not be_published
    end
    it "should not have the published at date set" do
      @object.save
      @object.published_at.should be_nil
    end
    describe "with save and publish" do
      before { @object.publish_on_save = true }
      it "should be published if saved with publish on save" do
        @object.save
        @object.should be_published
      end
      it "should have the published_at date set if published" do
        @object.save
        @object.published_at.should <= Time.now
      end      
    end
  end
end

describe "an existing publishable object" do
  before do
    @object = Publishable.create!(:name => "Existing Record")
  end
  it "should be publishable" do
    @object.should be_publishable
  end
  describe "that is published" do
    before do      
      @published_at = 5.minutes.ago
      @object.update_attributes(:published_at => @published_at, :publish_on_save => true)
    end
    it "should not change the published at when saved" do
      @object.published_at.should == @published_at
      @object.update_attributes(:name => "Changed", :publish_on_save => true)
      @object.published_at.should == @published_at
    end
  end
  describe "that is unpublished" do
    it "should set the published_at when published" do
      @object.published_at.should be_nil
      @object.publish!
      @object.published_at.should <= Time.now
    end
  end
end  

describe "a new unpublishable object" do
  before do
    @object = Unpublishable.new(:name => "New Record")    
  end
  it "should not be publishable" do
    @object.should_not be_publishable
  end
end

describe "a existing unpublishable object" do
  before do
    @object = Unpublishable.create!(:name => "Existing Record")    
  end
  it "should not be publishable" do
    @object.should_not be_publishable
  end
end

describe "a new connectable, publishable object" do
  before do
    @object = new_html_block
  end
  it "should be publishable" do
    @object.should be_publishable
  end
end

describe "an existing connectable, publishable object" do
  before do
    @object = create_html_block
  end
  it "should be publishable" do
    @object.should be_publishable
  end
end

describe "a publishable object being added to a page" do
  before do
    @page = create_page(:section => root_section)
    @object = new_html_block(:connect_to_page_id => @page.id, :connect_to_container => "test")
  end
  it "should not be publishable" do
    @object.should_not be_publishable
  end
end

describe "an existing connectable, publishable object that is connected to a page" do
  before do
    @page = create_page(:section => root_section)
    @object = create_html_block(:connect_to_page_id => @page.id, :connect_to_container => "test")
  end
  it "should not be publishable" do
    @object.should_not be_publishable
  end
end
