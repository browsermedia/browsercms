class Cms::ContentController < ApplicationController
  
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
      @file_metadata = FileMetadata.find_by_path(@path)
      raise "Access Denied" unless current_user.able_to_view?(@file_metadata)

      #Construct a path to where this file would be if it were cached
      @file = File.join(ActionController::Base.cache_store.cache_path, @path)

      #Write the file out if it doesn't exist
      unless File.exists?(@file)
        @file_metadata.write_file
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

  def check_access_to_page
    set_page_mode

    @page = logged_in? ? Page.first(:conditions => {:path => @path}) : Page.find_live_by_path(@path)

    page_not_found unless @page

    unless current_user.able_to_view?(@page)
      raise "Access Denied"
    end

    #Doing this so if you are logged in, you never see the cached page
    render_page if logged_in? || params[:cms_no_cache]

  end
  
  #-- Other Methods --
  def render_page
    render :layout => @page.layout, :action => 'show'
  end
  
  def page_not_found
    raise ActiveRecord::RecordNotFound.new("No page at '#{@path}'")
  end

  def set_page_mode
    @mode = params[:mode] || session[:page_mode] || "view"
    session[:page_mode] = @mode      
  end
  
  
end