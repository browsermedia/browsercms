class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name

      t.timestamps
    end
    ContentType.create!(:name => "Tag", :group_name => "Categorization")
  end

  def self.down
    drop_table :tags
  end
end
