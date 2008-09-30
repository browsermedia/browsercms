class CreatePages < ActiveRecord::Migration
  def self.up    
    create_versioned_table :pages do |t|
      t.integer :section_id
      t.integer :template_id
      t.string :name
      t.string :path
      t.string :status
      t.text :description
      t.string :user_date
      t.text :author
      t.text :source
      t.text :language
    end
    
  end

  def self.down
    drop_versioned_table :pages
  end
  
end
