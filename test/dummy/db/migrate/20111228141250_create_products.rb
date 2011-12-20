class CreateProducts < ActiveRecord::Migration
  def up
    Cms::ContentType.create!(:name => "Product", :group_name => "Product")
    create_content_table :products, :prefix=>false do |t|
      t.string :name
      t.integer :price

      t.timestamps
    end
  end

  def down

  end
end
