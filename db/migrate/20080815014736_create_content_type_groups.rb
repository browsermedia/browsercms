class CreateContentTypeGroups < ActiveRecord::Migration
  def self.up
    create_table :content_type_groups do |t|
      t.string :name

      t.timestamps
    end
    ContentTypeGroup.create!(:name => "Core")
  end

  def self.down
    drop_table :content_type_groups
  end
end
