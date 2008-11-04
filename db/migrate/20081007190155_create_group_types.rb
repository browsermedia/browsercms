class CreateGroupTypes < ActiveRecord::Migration
  def self.up
    create_table :group_types do |t|
      t.string :name
      t.boolean :guest, :default => false
      t.boolean :cms_access, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :group_types
  end
end
