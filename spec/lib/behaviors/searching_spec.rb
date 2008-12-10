require File.dirname(__FILE__) + '/../../spec_helper'

ActiveRecord::Base.connection.instance_eval do
  drop_table(:searchable_content_block_parents) if table_exists?(:searchable_content_block_parents)  
  create_table(:searchable_content_block_parents) {|t| t.string :name }
  drop_table(:searchable_content_blocks) if table_exists?(:searchable_content_blocks)
  drop_table(:searchable_content_block_versions) if table_exists?(:searchable_content_block_versions)
  create_versioned_table(:searchable_content_blocks) do |t| 
    t.integer :parent_id
    t.string :name 
    t.boolean :deleted, :default => 0
    t.integer :created_by
    t.integer :updated_by
    t.timestamps
  end
end

class SearchableContentBlockParent < ActiveRecord::Base
  has_many :children, :class_name => "SearchableContentBlock", :foreign_key => "parent_id" 
end

class SearchableContentBlock < ActiveRecord::Base
  acts_as_content_block
  belongs_to :parent, :class_name => "SearchableContentBlockParent"
  named_scope :created_after, lambda{|time| {:conditions => ["created_at > ?", time]}}
end

describe SearchableContentBlock do
  it "should be searchable" do
    @parent = SearchableContentBlockParent.create!(:name => "Papa")
    @a1 = @parent.children.create!(:name => "a1")
    @a2 = @parent.children.create!(:name => "a2")
    @b1 = @parent.children.create!(:name => "b1")
    @b2 = @parent.children.create!(:name => "b2")

    SearchableContentBlock.should be_searchable
    SearchableContentBlock.search("a").all.should == [@a1, @a2]
    SearchableContentBlock.search(:term => "a", :order => "id desc").all.should == [@a2, @a1]    
    SearchableContentBlock.created_after(1.hour.ago).search(:term => "a", :order => "id desc").all.should == [@a2, @a1]   
    @parent.children.created_after(1.hour.ago).search(:term => "a", :order => "id desc").all.should == [@a2, @a1]    
  end
end

describe HtmlBlock do
  it "should be searchable" do
    @a1 = create_html_block(:name => "a1", :content => "a one")
    @a2 = create_html_block(:name => "a2", :content => "a two")
    @b1 = create_html_block(:name => "b1", :content => "b one")
    @b2 = create_html_block(:name => "b2", :content => "b two")

    HtmlBlock.should be_searchable
    HtmlBlock.search("a").all.should == [@a1, @a2]
    HtmlBlock.search(:term => "one").all.should be_empty
    HtmlBlock.search(:term => "one", :include_body => true).all.should == [@a1, @b1]    
    HtmlBlock.search(nil).all.should == [@a1, @a2, @b1, @b2]
  end
end
