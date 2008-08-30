class Page < ActiveRecord::Base
  
  #See config/initializers/concered_with.rb
  concerned_with :status
  
  belongs_to :section
  belongs_to :template, :class_name => "PageTemplate"
  has_many :connectors, :dependent => :destroy
  
  before_validation :append_leading_slash_to_path
  
  validates_presence_of :section_id
  validates_uniqueness_of :path

  
  def append_leading_slash_to_path
    if path.blank?
      self.path = "/"
    elsif path[0,1] != "/"
      self.path = "/#{path}"
    end
  end
  
  def layout
    template ? template.file_name : nil
  end

  def template_name
    template ? template.name : nil
  end
  
end