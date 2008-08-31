class Mixin < ActiveRecord::Base
  belongs_to :parent_node, :class_name => 'Mixin', :foreign_key => 'parent_id'
end

class NestedSet < Mixin
  acts_as_nested_set :scope => "mixins.root_id IS NULL"
end

class NestedSetWithStringScope < Mixin
  acts_as_nested_set :scope => 'mixins.root_id = #{root_id}'
end

class NS1 < NestedSetWithStringScope
end

class NS2 < NS1    
  my_callbacks = [:before_create, :before_save, :before_update, :before_destroy, 
    :after_create, :after_save, :after_update, :after_destroy]
  my_callbacks.each do |sym|
    define_method(sym) do
      $callbacks ||= []
      $callbacks << sym
    end
  end    
end

class NestedSetWithSymbolScope < Mixin
  acts_as_nested_set :scope => :root
end

class Category < Mixin
  acts_as_nested_set
end
