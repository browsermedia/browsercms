require File.join(File.dirname(__FILE__), '/../../test_helper')

ActiveRecord::Base.connection.instance_eval do
  drop_table(:publishables) if table_exists?(:publishables)
  create_table(:publishables) do |t| 
    t.string :name
    t.boolean :published, :default => false
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
  end

  def test_publish_on_save
    @object = Publishable.new(:name => "New Record")
    @object.publish_on_save = true
    assert @object.save
    log_table_without_stamps Publishable
    assert @object.reload.published?
  end

  def test_unpublishable
    @object = Unpublishable.new(:name => "New Record")
    assert !@object.publishable?
    assert @object.save
    assert !@object.publishable?
  end
  
  def test_not_publishable_if_connect_to_page_id_is_blank
    assert HtmlBlock.new(:connect_to_page_id => "").publishable?
  end
  
end