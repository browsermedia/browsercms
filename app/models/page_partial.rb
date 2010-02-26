class PagePartial < DynamicView
  
  before_validation :prepend_underscore
  
  validates_format_of :name, :with => /\A_[a-z]+[a-z0-9_]*\Z/, :message => I18n.t("models.page_partial.name_format_error_message") 
  
  def file_path
    File.join(self.class.base_path, "partials", file_name)
  end  
  
  def self.display_name(file_name)
    name, format, handler = file_name.split('.')
    "#{name.sub(/^_/,'').titleize} (#{format}/#{handler})"
  end  
  
  def prepend_underscore
    if !name.blank? && name[0,1] != '_'
      self.name = "_#{name}"
    end
  end
  
end
