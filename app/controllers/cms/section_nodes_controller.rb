module Cms
  class SectionNodesController < Cms::BaseController

    layout 'cms/section_nodes'
    check_permissions :publish_content, :except => [:index]

    def index
      @toolbar_tab = :sitemap
      @modifiable_sections = current_user.modifiable_sections
      @public_sections = Group.guest.sections.all # Load once here so that every section doesn't need to.

      @sitemap = Section.sitemap
      @root_section_node = @sitemap.keys.first
      @section = @root_section_node.node
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
end
