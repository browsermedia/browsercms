class CreateSectionNodes < ActiveRecord::Migration
  def self.up
    create_table :section_nodes do |t|
      t.integer :section_id
      t.string :node_type
      t.integer :node_id
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :section_nodes
  end
end
