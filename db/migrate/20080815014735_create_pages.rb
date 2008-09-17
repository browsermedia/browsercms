# Notes indicate column mapping and datatype from CMS 2
class CreatePages < ActiveRecord::Migration
  def self.up    
    create_table :pages do |t|
      t.integer :version, :default => 1
      t.integer :section_id
      t.integer :template_id
      t.string :name
      t.string :path
      t.string :status
      t.text :description   #longtext
      t.string :user_date
      t.text :author
      t.text :source        #file_source longtext
      t.text :language      #text_language
      t.timestamps
    end
    
    create_table :page_versions do |t|
      t.integer :page_id
      t.integer :version, :default => 1
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
      t.timestamps
    end    
  end

  def self.down
    drop_table :page_versions
    drop_table :pages
  end
end
