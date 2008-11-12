class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_versioned_table :<%= table_name %> do |t|
<% for attribute in attributes -%>
      <%= 
        case attribute.type
        when :category
          @category_type = class_name.titleize
          "t.belongs_to :#{attribute.name}"
        when :attachment
          @attachment_section = class_name.titleize
          "t.belongs_to :#{attribute.name}" +
          "\n      t.integer :#{attribute.name}_version"
        else
          "t.#{attribute.type} :#{attribute.name}"
        end
      -%> 
<% end -%>
    end
    <% if @category_type %>CategoryType.create!(:name => "<%= @category_type %>")<% end %>
    <% if @attachment_section %>Section.create!(:name => "<%= @attachment_section %>", :parent => Section.system.first, :group_ids => Group.all(&:id))<% end %>      
    ContentType.create!(:name => "<%= class_name %>")
  end

  def self.down
    ContentType.delete_all(['name = ?', '<%= class_name %>'])
    CategoryType.all(:conditions => ['name = ?', '<%= class_name.titleize %>']).each(&:destroy)
    drop_table :<%= table_name.singularize %>_versions
    drop_table :<%= table_name %>
  end
end
