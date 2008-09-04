class PageTemplate < ActiveRecord::Base
  has_many :pages
  
  after_save :create_layout_file
  
  class << self
    attr_accessor :layout_path
  end
  self.layout_path = File.join(Rails.root, "tmp", "views", "layouts")

  def create_layout_file
    FileUtils.mkdir_p(self.class.layout_path)    
    open("#{self.class.layout_path}/#{file_name}.html.#{language}", "w") {|f| f << body }
  end
  
end