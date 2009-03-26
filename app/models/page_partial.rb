class PagePartial < DynamicView
  
  validates_format_of :name, :with => /\A_[a-z]+[a-z0-9_]*\Z/, :message => "can only contain lowercase letters, numbers and underscores and must begin with an underscore"  
  
  def file_path
    File.join(self.class.base_path, "partials", file_name)
  end  
  
end
