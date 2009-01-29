class Cms::SectionNodesController < Cms::BaseController
  check_permissions :publish_content, :only => [:move_before, :move_after]
  
  def index
    @toolbar_tab = :sitemap
    @section = Section.root.first
  end
  def move_before
    move(:before)
  end
  def move_after
    move(:after)
  end
  def move_to_beginning
    move_to(:beginning)
  end
  def move_to_end
    move_to(:end)
  end
  def move_to_root
    @section_node = SectionNode.find(params[:id])
    @root = Section.root.find(params[:section_id])
    @section_node.move_to(@root, 0)
    render :json => {:success => true, :message => "'#{@section_node.node.name}' was moved to '#{@root.name}'"}    
  end
  
  private
  def move(to)
    @section_node = SectionNode.find(params[:id])
    @other_node = SectionNode.find(params[:section_node_id])
    @section_node.send("move_#{to}", @other_node)
    render :json => {:success => true, :message => "'#{@section_node.node.name}' was moved #{to} '#{@other_node.node.name}'"}    
  end
  def move_to(place)
    @section_node = SectionNode.find(params[:id])
    @other_node = SectionNode.find(params[:section_node_id])
    @section_node.send("move_to_#{place}", @other_node.node)
    render :json => {:success => true, :message => "'#{@section_node.node.name}' was moved to the #{place} of '#{@other_node.node.name}'"}            
  end
end
