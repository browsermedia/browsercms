class CreatePages < ActiveRecord::Migration
  def self.up    
    create_versioned_table :pages do |t|
      t.integer :template_id
      t.string :name
      t.string :path
      t.text :description
      t.string :user_date
      t.string :author
      t.string :source
      t.string :language
      t.boolean :hidden, :default => false
      t.boolean :archived, :default => false
    end
    
  end

  def self.down
    drop_versioned_table :pages
  end
  
end
