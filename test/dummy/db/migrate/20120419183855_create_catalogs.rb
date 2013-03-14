class CreateCatalogs < ActiveRecord::Migration
  def change
    create_content_table :catalogs, :prefix=>false do |t|
      t.string :name

      t.timestamps
    end
  end
end
