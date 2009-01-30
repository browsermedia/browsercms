class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.belongs_to :category_type
      t.belongs_to :parent
      t.string :name

      t.timestamps
    end
    ContentType.create!(:name => "Category", :group_name => "Categorization")
  end

  def self.down
    drop_table :categories
  end
end
