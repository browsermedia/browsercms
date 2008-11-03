class Cms::SectionNodesController < Cms::BaseController
  check_permissions :publish_content, :only => [:move_before, :move_after]

  def index
    @section = Section.root.first
  end
  def move_before
    move(:before)
  end
  def move_after
    move(:after)
  end
  
  private
  def move(to)
    @section_node = SectionNode.find(params[:id])
    @other_node = SectionNode.find(params[:section_node_id])
    @section_node.send("move_#{to}", @other_node)
    render :json => {:success => true, :message => "'#{@section_node.node.name}' was moved #{to} '#{@other_node.node.name}'"}    
  end
  
end