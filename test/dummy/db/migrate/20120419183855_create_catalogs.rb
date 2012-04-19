class CreateCatalogs < ActiveRecord::Migration
  def change
    Cms::ContentType.create!(:name => "Catalog", :group_name => "Testing")
    create_content_table :catalogs, :prefix=>false do |t|
      t.string :name

      t.timestamps
    end
  end
end
