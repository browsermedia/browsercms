module Cms
  class SectionNodesController < Cms::BaseController

    check_permissions :publish_content, :except => [:index]

    def index
      @modifiable_sections = current_user.modifiable_sections
      @public_sections = Group.guest.sections.to_a # Load once here so that every section doesn't need to.

      @sitemap = Section.sitemap
      @root_section_node = @sitemap.keys.first
      @section = @root_section_node.node
      render 'show'
    end

    def move_to_position
      @section_node = SectionNode.find(params[:id])
      target_node = SectionNode.find(params[:target_node_id])
      @section_node.move_to(target_node.node, params[:position].to_i)
      render :json => {:success => true, :message => "'#{@section_node.node.name}' was moved to '#{target_node.node.name}'"}
    end

  end
end
