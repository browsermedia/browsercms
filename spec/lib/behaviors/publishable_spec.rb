require File.dirname(__FILE__) + '/../../spec_helper'

ActiveRecord::Base.connection.instance_eval do
  drop_table(:publishables) if table_exists?(:publishables)
  create_table(:publishables) do |t| 
    t.string :name
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
end

describe "an existing publishable object" do
  before do
    @object = Publishable.create!(:name => "Existing Record")
  end
  it "should be publishable" do
    @object.should be_publishable
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

describe "an existing connectable, publishable object that is connected to a page" do
  before do
    @page = create_page(:section => root_section)
    @object = create_html_block(:connect_to_page_id => @page.id, :connect_to_container => "test")
  end
  it "should not be publishable" do
    @object.should_not be_publishable
  end
end
