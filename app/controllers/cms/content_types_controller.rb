class Cms::ContentTypesController < Cms::BaseController
  layout 'cms/thickbox'
  def select
    @content_types = ContentType.find(:all, :order => 'name')
  end
end
