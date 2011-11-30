require 'test_helper'

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

class DynamicAttributesTest < ActiveSupport::TestCase

  def setup
    @thing = Thing.new
  end

  test "blocks should not have dynamic_attributes" do
    assert !Cms::User.has_dynamic_attributes?

  end

  test "models should have dynamic_attributes if specified" do
    assert Thing.has_dynamic_attributes?
  end

  test "can just call properties into existance" do
    @thing.price = 1

    assert_equal(1, @thing.price)
  end

  test "Can persist String properties" do
    @thing.description = "A thing"
    @thing.save!

    reloaded_thing = Thing.find(@thing.id)
    assert_equal("A thing", reloaded_thing.description)
  end

  test "non-string (like Integers) properties are persisted as Strings" do
    @thing.price = 1
    @thing.save!

    reloaded_thing = Thing.find(@thing.id)
    assert_equal("1", reloaded_thing.price)
  end

  test "undefined properties should be nil" do
    assert_nil @thing.non_yet_set_property
  end

  test "can bulk set attributes=" do
    @thing.attributes=({:price=>1, :description=>"Paper"})
    assert_equal(1, @thing.price)
    assert_equal("Paper", @thing.description)
  end

  test "can bulk set persistent properties during construction" do
    mineral = Thing.new(:description=>"Rock")
    mineral.save!

    assert_equal("Rock", mineral.description)
  end
end