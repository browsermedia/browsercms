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
end

describe VersionedArticle do
  it "should be taggable"
end