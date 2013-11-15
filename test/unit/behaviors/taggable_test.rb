require 'test_helper'

ActiveRecord::Base.connection.instance_eval do
  drop_table(:taggable_articles) if table_exists?(:taggable_articles)
  create_table(:taggable_articles) {|t| t.string :name }

  drop_table(:versioned_taggable_articles) if table_exists?(:versioned_taggable_articles)
  drop_table(:versioned_taggable_article_versions) if table_exists?(:versioned_taggable_article_versions)
  create_content_table(:versioned_taggable_articles) do |t|
    t.string :name
  end
end

class TaggableArticle < ActiveRecord::Base
  is_taggable

 #attr_accessible :name, :tag_list
end

class VersionedTaggableArticle < ActiveRecord::Base
  #attr_accessible :name
  acts_as_content_block :taggable => true
end

class TaggableBlockTest < ActiveSupport::TestCase
  def test_tagging
    article = TaggableArticle.create!(:name => "foo")
    assert_equal 0, article.taggings.count
    assert_equal 0, article.tags.count
    assert_equal 0, Cms::Tag.count
    assert_equal 0, Cms::Tagging.count

    article.tag_list = "foo bar"
    assert article.save
    assert_equal 2, article.taggings.count
    assert_equal 2, article.tags.count
    assert_equal 2, Cms::Tag.count
    assert_equal 2, Cms::Tagging.count
    
    assert_equal [article], TaggableArticle.tagged_with("foo").to_a
    assert_equal [article], TaggableArticle.tagged_with("bar").to_a
    assert TaggableArticle.tagged_with("bang").to_a.empty?
        
    article.tag_list = "foo bang"
    assert article.save
    assert_equal 2, article.taggings.count
    assert_equal 2, article.tags.count
    assert_equal 3, Cms::Tag.count
    assert_equal 2, Cms::Tagging.count

    assert_equal [article], TaggableArticle.tagged_with("foo").to_a
    assert_equal [article], TaggableArticle.tagged_with("bang").to_a
    assert TaggableArticle.tagged_with("bar").to_a.empty?
    
    assert_equal "bang foo", article.tag_list
  end
  
  def test_tag_cloud
    25.times do |n|
      tag_list = ["article"]
      tag_list << "first" if n == 0
      tag_list << "even" if n.even?
      tag_list << "five" if n % 5 == 0
      tag_list << "last" if n == 24
      TaggableArticle.create!(:name => "Article ##{n}", :tag_list => tag_list.join(" ") )
    end
    
    tags_summary = Cms::Tag.counts.limit(4).to_a
    assert_equal 4, tags_summary.size
    assert_equal Cms::Tag.find_by_name("article"), tags_summary[0]
    assert_equal 25, tags_summary[0].count.to_i
    assert_equal Cms::Tag.find_by_name("even"), tags_summary[1]
    assert_equal 13, tags_summary[1].count.to_i
    assert_equal Cms::Tag.find_by_name("five"), tags_summary[2]
    assert_equal 5, tags_summary[2].count.to_i
    assert_equal Cms::Tag.find_by_name("first"), tags_summary[3]
    assert_equal 1, tags_summary[3].count.to_i

    
    tag_cloud = Cms::Tag.cloud(:sizes => 9)
    assert_equal 5, tag_cloud.size
    assert_equal Cms::Tag.find_by_name("article"), tag_cloud[0]
    assert_equal 6, tag_cloud[0].size
    assert_equal Cms::Tag.find_by_name("even"), tag_cloud[1]
    assert_equal 3, tag_cloud[1].size
    assert_equal Cms::Tag.find_by_name("five"), tag_cloud[2]
    assert_equal 1, tag_cloud[2].size
    assert_equal Cms::Tag.find_by_name("first"), tag_cloud[3]
    assert_equal 0, tag_cloud[3].size
    assert_equal Cms::Tag.find_by_name("last"), tag_cloud[4]
    assert_equal 0, tag_cloud[4].size
  end
  
end

class VersionedTaggableBlockTest < ActiveSupport::TestCase
  def test_tagging
    article = VersionedTaggableArticle.create!(:name => "foo")
    assert_equal 0, article.taggings.count
    assert_equal 0, article.tags.count
    assert_equal 0, Cms::Tag.count
    assert_equal 0, Cms::Tagging.count

    article.tag_list = "foo bar"
    assert article.save
    assert_equal 2, article.taggings.count
    assert_equal 2, article.tags.count
    assert_equal 2, Cms::Tag.count
    assert_equal 2, Cms::Tagging.count
  end

  
end
