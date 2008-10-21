class Cms::SectionNodesController < Cms::BaseController
  def index
    @section = Section.root.first
  end
end