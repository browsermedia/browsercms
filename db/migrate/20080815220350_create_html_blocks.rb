class CreateHtmlBlocks < ActiveRecord::Migration
  def self.up
    create_versioned_table :html_blocks do |t|
      t.string :name
      t.string :content
      t.string :status
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_versioned_table :html_blocks
  end
end
