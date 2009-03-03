require File.join(File.dirname(__FILE__), '/../../test_helper')

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

class ThingTest < ActiveSupport::TestCase
  def test_dynamic_attributes
    assert !User.has_dynamic_attributes?
    assert Thing.has_dynamic_attributes?

    thing = Thing.new(:foo => "bar")
    assert_equal "bar", thing.foo

    thing.foo = "Bang"
    assert_equal "Bang", thing.foo

    assert thing.save

    thing = Thing.find(thing.id)
    assert_equal "Bang", thing.foo
    assert_nil thing.bar
  end
end
