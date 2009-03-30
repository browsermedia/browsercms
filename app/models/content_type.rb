class ContentType < ActiveRecord::Base

  attr_accessor :group_name
  belongs_to :content_type_group
  validates_presence_of :content_type_group
  before_validation :set_content_type_group
  
  named_scope :named, lambda{|name| {:conditions => ['content_types.name = ?', name]}}
  
  named_scope :connectable, 
    :include => :content_type_group,
    :conditions => ['content_type_groups.name != ?', 'Categorization'],
    :order => 'content_types.priority, content_types.name'
  
  def self.list
    all.map { |f| f.name.underscore.to_sym }
  end
   
  # Given a 'key' like 'html_blocks' or 'portlet'
  # Raises exception if nothing was found.
  def self.find_by_key(key)
    class_name = key.classify
    content_type = find_by_name(class_name)
    if content_type.nil?
      if class_name.constantize.ancestors.include?(Portlet)
        content_type = ContentType.new(:name => class_name)
        content_type.content_type_group = ContentTypeGroup.find_by_name('Core')
        content_type.freeze
        content_type
      else
        raise "Not a Portlet"
      end
    else
      content_type
    end
  rescue Exception
    raise "Couldn't find ContentType of class '#{class_name}'"    
  end
  
  def is_child_of?(content_type)
    name.constantize.ancestors.map{|c| c.name}.include?(content_type.name)  
  end
  
  def form
    model_class.respond_to?(:form) ? model_class.form : "cms/#{name.underscore.pluralize}/form"
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

  # Allows models to show additional columns when being shown in a list.
  def columns_for_index
    if model_class.respond_to?(:columns_for_index)
      model_class.columns_for_index.map do |column|
        column.respond_to?(:humanize) ? {:label => column.humanize, :method => column} : column
      end
    else
      [{:label => "Name", :method => :name, :order => "name"},
       {:label => "Updated On", :method => :updated_on_string, :order => "updated_at"}]
    end
  end

  # Used in ERB for pathing
  def content_block_type
    name.pluralize.underscore
  end
  
  # This is used for situations where you want different to use a type for the list page
  # This is true for portlets, where you don't want to list all portlets of a given type,
  # You want to list all portlets
  def content_block_type_for_list
    if model_class.respond_to?(:content_block_type_for_list)
      model_class.content_block_type_for_list
    else
      content_block_type
    end
  end
  
  def set_content_type_group
    if group_name
      group = ContentTypeGroup.first(:conditions => {:name => group_name})
      self.content_type_group = group || build_content_type_group(:name => group_name)
    end
  end
  
end
