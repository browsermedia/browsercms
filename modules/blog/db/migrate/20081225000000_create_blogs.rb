class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.string :name
      t.string :format
      t.string :path
    end
    ContentType.create!(:name => "Blog", :group_name => "Blog")
  end

  def self.down
    ContentType.delete_all(['name = ?', 'Blog'])
    drop_table :blogs
  end
end
