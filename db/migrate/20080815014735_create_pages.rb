class CreatePages < ActiveRecord::Migration
  def self.up    
    create_table :pages do |t|
      t.integer :version, :default => 1
      t.integer :section_id, :integer
      t.integer :template_id, :integer
      t.string :name
      t.string :path
      t.string :status
      t.timestamps
    end
    
    create_table :page_versions do |t|
      t.integer :page_id
      t.integer :version, :default => 1
      t.integer :section_id, :integer
      t.integer :template_id, :integer
      t.string :name
      t.string :path
      t.string :status
      t.timestamps
    end    
  end

  def self.down
    drop_table :page_versions
    drop_table :pages
  end
end
