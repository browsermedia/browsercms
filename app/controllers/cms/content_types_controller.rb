class Cms::ContentTypesController < Cms::BaseController

  def index
    @content_types = ContentType.find(:all, :order => 'name')
  end
  
end
