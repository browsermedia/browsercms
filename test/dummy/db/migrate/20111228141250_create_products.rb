class CreateProducts < ActiveRecord::Migration
  def up
    create_content_table :products, :prefix=>false do |t|
      t.string :name
      t.integer :price
      t.integer :category_id
      t.boolean :on_special
      t.timestamps
    end
  end

  def down

  end
end
