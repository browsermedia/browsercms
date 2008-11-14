class ContentType < ActiveRecord::Base

  attr_accessor :group_name
  belongs_to :content_type_group
  validates_presence_of :content_type_group
  before_validation :set_content_type_group

  def self.list
    all.map { |f| f.name.underscore.to_sym }
  end
  
  # Given a 'key' like 'html_blocks' or 'portlet'
  # Raises exception if nothing was found.
  def self.find_by_key(key)
    content_type = find_by_name(key.classify)
    if content_type.nil?
      raise "Couldn't find ContentType of class '#{key.classify}'"
    end
    content_type
  end
  
  def display_name
    model_class.respond_to?(:display_name) ? model_class.display_name : model_class.to_s.titleize
  end

  def display_name_plural
    model_class.respond_to?(:display_name_plural) ? model_class.display_name_plural : display_name.pluralize
  end

  def model_class
    name.classify.constantize
  end

  # Allows models to override which view is displayed with BlockController#new is called.
  def template_for_new
    if model_class.respond_to?("template_for_new")
      return model_class.template_for_new
    end
    "cms/blocks/new"
  end
  
   # Allows models to override which view is displayed with BlockController#edit is called.
  def template_for_edit
    if model_class.respond_to?("template_for_edit")
      return model_class.template_for_edit
    end
    "cms/blocks/edit"
  end

  # Allows models to show additional columns when being shown in a list.
  def columns_for_index
    if model_class.respond_to?("columns_for_index")
      columns_for_index = model_class.columns_for_index
      final_list = []
      columns_for_index.each do |column|
        if column.respond_to?(:humanize)
          final_list << {:label => column.humanize, :method => column}
        else
          final_list << column
        end
      end
      return final_list
    end
    return []
  end

  # Used in ERB for pathing
  def content_block_type
    name.pluralize.underscore
  end
  
  def set_content_type_group
    if group_name
      group = ContentTypeGroup.first(:conditions => {:name => group_name})
      self.content_type_group = group || build_content_type_group(:name => group_name)
    end
  end
  
  
end
