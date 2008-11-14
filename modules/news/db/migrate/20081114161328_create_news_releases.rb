class CreateNewsReleases < ActiveRecord::Migration
  def self.up
    create_versioned_table :news_releases do |t|
      t.string :name 
      t.date :release_date 
      t.belongs_to :category 
      t.belongs_to :attachment
      t.integer :attachment_version 
      t.text :summary 
      t.text :body, :size => (64.kilobytes + 1) 
    end
    CategoryType.create!(:name => "News Release")
    Section.create!(:name => "News Release", :parent => Section.system.first, :group_ids => Group.all(&:id))      
    ContentType.create!(:name => "NewsRelease", :group_name => "News")
  end

  def self.down
    ContentType.delete_all(['name = ?', 'NewsRelease'])
    CategoryType.all(:conditions => ['name = ?', 'News Release']).each(&:destroy)
    drop_table :news_release_versions
    drop_table :news_releases
  end
end
