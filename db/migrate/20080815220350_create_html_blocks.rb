class CreateHtmlBlocks < ActiveRecord::Migration
  def self.up
    create_versioned_table :html_blocks do |t|
      t.string :name
      t.string :content, :limit => 64.kilobytes + 1
    end
    ContentType.create!(:name => "HtmlBlock", :group_name => "Core", :priority => 1)
  end

  def self.down
    drop_versioned_table :html_blocks
  end
end
