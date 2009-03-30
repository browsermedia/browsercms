class CreateContentTypes < ActiveRecord::Migration
  def self.up
    create_table :content_types do |t|
      t.string :name
      t.belongs_to :content_type_group
      t.integer :priority, :default => 2
      t.timestamps
    end
  end

  def self.down
    drop_table :content_types
  end
end
