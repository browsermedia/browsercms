class ContentType < ActiveRecord::Base

  def display_name
    model_class.display_name
  end

  def display_name_plural
    model_class.display_name_plural
  end

  def model_class
    name.classify.constantize
  end

  # Used in ERB for pathing
  def content_block_type
    name.pluralize.underscore
  end
end
