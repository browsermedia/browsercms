class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_versioned_table :<%= table_name %> do |t|
<% for attribute in attributes -%>
      t.<%= 
        case attribute.type
        when :category
          @category_type = class_name.titleize
          "belongs_to"
        else
          attribute.type
        end
      -%> :<%= attribute.name %>
<% end -%>
    end
    <% if @category_type %>CategoryType.create!(:name => "<%= @category_type %>")<% end %>
    ContentType.create!(:name => "<%= class_name %>")
  end

  def self.down
    ContentType.delete_all(['name = ?', '<%= class_name %>'])
    CategoryType.all(:conditions => ['name = ?', '<%= class_name.titleize %>']).each(&:destroy)
    drop_table :<%= table_name.singularize %>_versions
    drop_table :<%= table_name %>
  end
end
