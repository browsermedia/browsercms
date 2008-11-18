class Cms::ContentController < Cms::ApplicationController
  
  before_filter :construct_path
  before_filter :try_to_redirect
  before_filter :try_to_stream_file
  before_filter :check_access_to_page
  caches_action :show
  
  def show        
    render_page
  end

  private

  #-- Filters --
  def construct_path
    @path = "/#{params[:path].join("/")}"    
  end
  
  def try_to_redirect
    if redirect = Redirect.find_by_from_path(@path)
      redirect_to redirect.to_path
    end    
  end

  def try_to_stream_file
    split = params[:path].last.to_s.split('.')
    ext = split.size > 1 ? split.last.to_s.downcase : nil
    
    #Only try to stream cache file if it has an extension
    unless ext.blank?
      
      #Check access to file
      @attachment = Attachment.find_live_by_file_name(@path)
      if @attachment
        raise Cms::Errors::AccessDenied unless current_user.able_to_view?(@attachment)

        #Construct a path to where this file would be if it were cached
        @file = File.join(ActionController::Base.cache_store.cache_path, @path)

        #Write the file out if it doesn't exist
        unless File.exists?(@file)
          @attachment.write_file
        end
    
        #Stream the file if it exists
        if @path != "/" && File.exists?(@file)
          send_file(@file, 
            :type => Mime::Type.lookup_by_extension(ext).to_s,
            :disposition => false #see monkey patch in lib/action_controller/streaming.rb
          ) 
        end    
      end
    end    
    
  end

  def check_access_to_page

    if current_user.able_to?(:edit_content, :publish_content)
      @page = Page.first(:conditions => {:path => @path})
      page_not_found unless @page
    else
      @page = Page.find_live_by_path(@path)
      page_not_found unless (@page && !@page.archived?)
    end

    unless current_user.able_to_view?(@page)
      raise Cms::Errors::AccessDenied
    end

    #Doing this so if you are logged in, you never see the cached page
    if logged_in?
      logger.info "Not Caching, user is logged in"
      render_page
    elsif !@page.cacheable?
      logger.info "Not Caching, page cachable is false"
      render_page
    elsif params[:cms_cache] == "false"
      logger.info "Not Caching, cms_cache is false"
      render_page
    end

  end
  
  #-- Other Methods --
  def render_page
    render :layout => @page.layout, :action => 'show'
  end
  
  def page_not_found
    raise ActiveRecord::RecordNotFound.new("No page at '#{@path}'")
  end

  
end