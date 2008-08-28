class Cms::ContentTypesController < Cms::BaseController
  def select
    @content_types = ContentType.find(:all, :order => 'label')
  end
end