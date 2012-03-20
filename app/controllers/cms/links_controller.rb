module Cms
class LinksController < Cms::BaseController

  before_filter :set_toolbar_tab
  before_filter :load_section, :only => [:new, :create, :move_to]
  before_filter :load_link, :only => [:destroy, :update]
  before_filter :load_draft_link, :only => [:edit]
  
  def new
    @link = Link.new(:section => @section)
  end

  def create
    @link = Link.new(params[:link])
    @link.section = @section
    if @link.save
      flash[:notice] = "Link was '#{@link.name}' created."
      redirect_to @section
    else
      render :action => "new"
    end
  end
  
  def update
    if @link.update_attributes(params[:link])
      flash[:notice] = "Link '#{@link.name}' was updated"
      redirect_to @link.section
    else
      render :action => 'edit'
    end      
  end
  
  def destroy
    respond_to do |format|
      if @link.destroy
        message = "Link '#{@link.name}' was deleted."
        format.html { flash[:notice] = message; redirect_to(sitemap_url) }
        format.json { render :json => {:success => true, :message => message } }
      else
        message = "Link '#{@link.name}' could not be deleted"
        format.html { flash[:error] = message; redirect_to(sitemap_url) }
        format.json { render :json => {:success => false, :message => message } }
      end
    end    
  end

  protected

    def load_section
      @section = Section.find(params[:section_id])
      raise Cms::Errors::AccessDenied unless current_user.able_to_edit?(@section)
    end

    def load_link
      @link = Link.find(params[:id])
      raise Cms::Errors::AccessDenied unless current_user.able_to_edit?(@link)
    end
    
    def load_draft_link
      load_link
      @link = @link.as_of_draft_version
    end

    def set_toolbar_tab
      @toolbar_tab = :sitemap
    end

end
end