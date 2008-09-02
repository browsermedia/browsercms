class CreateHtmlBlocks < ActiveRecord::Migration
  def self.up
    create_table :html_blocks do |t|
      t.string :name
      t.string :content
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :html_blocks
  end
end
