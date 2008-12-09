class Cms::ContentTypesController < Cms::BaseController
  def select
    @toolbar_tab = :content_library
    @content_types = ContentType.find(:all, :order => 'name')
  end
end
