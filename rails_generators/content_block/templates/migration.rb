class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_versioned_table :<%= table_name %> do |t|
<% for attribute in attributes -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>
    end
    ContentType.create!(:name => "<%= class_name %>")
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
