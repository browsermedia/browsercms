class PageTemplate < ActiveRecord::Base
  has_many :pages
  
  after_save :create_layout_file
  
  def create_layout_file
    open("#{Rails.root}/tmp/views/layouts/#{file_name}.html.#{language}", "w") {|f| f << body }
  end
  
end