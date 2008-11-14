class CreateCategoryTypes < ActiveRecord::Migration
  def self.up
    create_table :category_types do |t|
      t.string :name

      t.timestamps
    end
    ContentType.create!(:name => "CategoryType", :group_name => "Categories")
  end

  def self.down
    drop_table :category_types
  end
end
