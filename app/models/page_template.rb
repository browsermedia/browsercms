class PageTemplate < ActiveRecord::Base
  has_many :pages
  def path
    "templates/#{file_name}"
  end  
end