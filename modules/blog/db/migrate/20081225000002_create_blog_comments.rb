class CreateBlogComments < ActiveRecord::Migration
  def self.up
    create_table :blog_comments do |t|
      t.integer :post_id
      t.string :author
      t.string :email
      t.string :url
      t.string :ip
      t.text :body
    end
    ContentType.create!(:name => "BlogComment", :group_name => "Blog")    
  end

  def self.down
    ContentType.delete_all(['name = ?', 'BlogComment'])
    drop_table :blog_comments
  end
end
