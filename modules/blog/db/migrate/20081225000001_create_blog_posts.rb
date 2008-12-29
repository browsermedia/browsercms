class CreateBlogPosts < ActiveRecord::Migration
  def self.up
    create_versioned_table :blog_posts do |t|
      t.integer :blog_id
      t.integer :author_id
      t.string :name 
      t.string :slug
      t.text :summary 
      t.text :body, :size => (64.kilobytes + 1) 
      t.datetime :published_at
    end
    CategoryType.create!(:name => "Blog Post")
    ContentType.create!(:name => "BlogPost", :group_name => "Blog")
  end

  def self.down
    ContentType.delete_all(['name = ?', 'BlogPost'])
    CategoryType.all(:conditions => ['name = ?', 'Blog Post']).each(&:destroy)
    drop_table :blog_post_versions
    drop_table :blog_posts
  end
end
