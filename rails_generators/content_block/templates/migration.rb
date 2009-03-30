class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_versioned_table :<%= table_name %> do |t|
<% for attribute in attributes -%>
      <%= 
        case attribute.type
        when :category
          @category_type = class_name.titleize
          "t.belongs_to :category"
        when :attachment
          @attachment_section = class_name.titleize
          "t.belongs_to :attachment" +
          "\n      t.integer :attachment_version"
        when :html
          "t.text :#{attribute.name}, :size => (64.kilobytes + 1)"
        else
          "t.#{attribute.type} :#{attribute.name}"
        end
      -%> 
<% end -%>
    end
    <% if @category_type %>unless CategoryType.named('<%= @category_type %>').exists?
      CategoryType.create!(:name => "<%= @category_type %>")
    end<% end %>
    <% if @attachment_section %>unless Section.with_path('/<%= file_name.pluralize %>').exists?
      Section.create!(:name => "<%= @attachment_section %>", :parent => Section.system.first, :path => '/<%= file_name.pluralize %>', :group_ids => Group.all(&:id))
    end<% end %>
    ContentType.create!(:name => "<%= class_name %>", :group_name => "<%= class_name %>")
  end

  def self.down
    ContentType.delete_all(['name = ?', '<%= class_name %>'])
    CategoryType.all(:conditions => ['name = ?', '<%= class_name.titleize %>']).each(&:destroy)
    drop_table :<%= table_name.singularize %>_versions
    drop_table :<%= table_name %>
  end
end
