require File.dirname(__FILE__) + '/../../spec_helper'

ActiveRecord::Base.connection.instance_eval do
  drop_table(:articles) if table_exists?(:articles)
  create_table(:articles) {|t| t.string :name }

  drop_table(:versioned_articles) if table_exists?(:versioned_articles)
  drop_table(:versioned_article_versions) if table_exists?(:versioned_article_versions)
  create_versioned_table(:versioned_articles) do |t| 
    t.string :name
  end
end

class Article < ActiveRecord::Base
  is_taggable
end

class VersionedArticle < ActiveRecord::Base
  acts_as_content_block :taggable => true
end

describe Article do
  it "should be taggable" do
    article = Article.create!(:name => "foo")
    article.taggings.count.should == 0
    article.tags.count.should == 0
    Tag.count.should == 0
    Tagging.count.should == 0

    article.tag_list = "foo bar"
    article.save
    article.taggings.count.should == 2
    article.tags.count.should == 2
    Tag.count.should == 2
    Tagging.count.should == 2
    
    Article.tagged_with("foo").all.should == [article]
    Article.tagged_with("bar").all.should == [article]
    Article.tagged_with("bang").all.should be_blank
        
    article.tag_list = "foo bang"
    article.save
    article.taggings.count.should == 2
    article.tags.count.should == 2
    Tag.count.should == 3
    Tagging.count.should == 2

    Article.tagged_with("foo").all.should == [article]
    Article.tagged_with("bang").all.should == [article]
    Article.tagged_with("bar").all.should be_blank
    
    article.tag_list.should == "bang foo"
  end
  
  it "should have a tag cloud" do
    25.times do |n|
      tag_list = ["article"]
      tag_list << "first" if n == 0
      tag_list << "even" if n.even?
      tag_list << "five" if n % 5 == 0
      tag_list << "last" if n == 24
      Article.create!(:name => "Article ##{n}", :tag_list => tag_list.join(" ") )
    end
    
    tag_counts = Tag.counts(:limit => 4)
    tag_counts.size.should == 4
    tag_counts[0].should == Tag.find_by_name("article")
    tag_counts[0].count.should == "25"
    tag_counts[1].should == Tag.find_by_name("Even")
    tag_counts[1].count.should == "13"
    tag_counts[2].should == Tag.find_by_name("Five")
    tag_counts[2].count.should == "5"
    tag_counts[3].should == Tag.find_by_name("First")
    tag_counts[3].count.should == "1"
    
    tag_cloud = Tag.cloud(:sizes => 9)
    tag_cloud.size.should == 5
    tag_cloud[0].should == Tag.find_by_name("article")
    tag_cloud[0].size.should == 7
    tag_cloud[1].should == Tag.find_by_name("Even")
    tag_cloud[1].size.should == 4
    tag_cloud[2].should == Tag.find_by_name("Five")
    tag_cloud[2].size.should == 2
    tag_cloud[3].should == Tag.find_by_name("First")
    tag_cloud[3].size.should == 1
    tag_cloud[4].should == Tag.find_by_name("Last")
    tag_cloud[4].size.should == 1
    
  end
  
end

describe VersionedArticle do
  it "should be taggable" do
    pending "Tagging should work as expected with a versioned model"
    article = VersionedArticle.create!(:name => "foo")
    article.taggings.count.should == 0
    article.tags.count.should == 0
    Tag.count.should == 0
    Tagging.count.should == 0

    article.tag_list = "foo bar"
    article.save
    article.taggings.count.should == 2
    article.tags.count.should == 2
    Tag.count.should == 2
    Tagging.count.should == 2
    
    VersionedArticle.tagged_with("foo").all.should == [article]
    VersionedArticle.tagged_with("bar").all.should == [article]
    VersionedArticle.tagged_with("bang").all.should be_blank
        
    article.tag_list = "foo bang"
    article.save
    article.taggings.count.should == 2
    article.tags.count.should == 2
    Tag.count.should == 3
    Tagging.count.should == 4

    VersionedArticle.tagged_with("foo").all.should == [article]
    VersionedArticle.tagged_with("bang").all.should == [article]
    VersionedArticle.tagged_with("bar").all.should be_blank
    
    article.tag_list.should == "bang foo"
    
  end
end