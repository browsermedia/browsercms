require File.join(File.dirname(__FILE__), '/../../test_helper')

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

class PublishableTestCase < ActiveSupport::TestCase
  def test_publishable
    @object = Publishable.new(:name => "New Record")
    assert @object.publishable?
  end
  
  def test_save
    @object = Publishable.new(:name => "New Record")
    assert @object.save
    assert !@object.published?
    assert_nil @object.published_at
  end

  def test_publish_on_save
    @object = Publishable.new(:name => "New Record")
    @object.publish_on_save = true
    assert @object.save
    assert @object.published?
    assert @object.published_at <= Time.now
  end

  def test_published_at_does_not_change
    @object = Publishable.create(:name => "New Record")
    @published_at = 5.minutes.ago
    assert @object.update_attributes(:published_at => @published_at, :publish_on_save => true)
    assert_equal @published_at, @object.published_at
    assert @object.update_attributes(:name => "Changed", :publish_on_save => true)
    assert_equal @published_at, @object.published_at
  end
  
  def test_unpublishable
    @object = Unpublishable.new(:name => "New Record")
    assert !@object.publishable?
    assert @object.save
    assert !@object.publishable?
  end
  
end