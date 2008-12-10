require File.dirname(__FILE__) + '/../../spec_helper'

ActiveRecord::Base.connection.instance_eval do
  drop_table(:things) if table_exists?(:things)
  drop_table(:thing_attributes) if table_exists?(:thing_attributes)
  create_table(:things) do |t| 
    t.string :name
    t.timestamps
  end
  create_table(:thing_attributes) do |t| 
    t.integer :thing_id
    t.string :name
    t.text :value
  end
end

class Thing < ActiveRecord::Base
  has_dynamic_attributes
end

describe Thing do
  it "should have dynamic attrbiutes" do
    User.has_dynamic_attributes?.should_not be_true
    Thing.has_dynamic_attributes?.should be_true
    
    thing = Thing.new(:foo => "bar")
    thing.foo.should == "bar"
    thing.foo = "Bang"
    thing.foo.should == "Bang"
    thing.save
    
    thing = Thing.find(thing.id)
    thing.foo.should == "Bang"
    thing.bar.should be_nil
    
  end
end