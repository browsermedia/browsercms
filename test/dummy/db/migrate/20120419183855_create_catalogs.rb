class CreateCatalogs < ActiveRecord::Migration
  def change
    create_content_table :catalogs do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
