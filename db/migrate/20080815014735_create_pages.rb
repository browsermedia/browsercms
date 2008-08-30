class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer :section_id
      t.integer :template_id
      t.string :name
      t.string :path
      t.string :status
      
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
