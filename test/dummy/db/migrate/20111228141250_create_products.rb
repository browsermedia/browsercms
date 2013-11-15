class CreateProducts < ActiveRecord::Migration
  def change
    create_content_table :products do |t|
      t.string :name
      t.integer :price
      t.integer :category_id
      t.boolean :on_special
      t.timestamps
    end
  end
end
