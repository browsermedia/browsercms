class ContentType < ActiveRecord::Base

  # Factory Method to create a new instance of the Content Type
  # (i.e. if model_class == HtmlBlock, create a new one of those)
  #
  # @params - Hash of request parameters which will bound to the new model
  def new_content(params = {})
    model_class.new(params)
  end
  
  # Given a 'key' like 'html_blocks' or 'portlet'
  def self.find_by_key(key)
    find_by_name(key.classify)
  end
  
  def display_name
    model_class.display_name
  end

  def display_name_plural
    model_class.display_name_plural
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
  
  # Used in ERB for pathing
  def content_block_type
    name.pluralize.underscore
  end
end
