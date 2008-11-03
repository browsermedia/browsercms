class Cms::ContentController < ApplicationController
  
  def show

    #Reconstruct the path from an array into a string
    @path = "/#{params[:path].join("/")}"

    #Try to Redirect
    if redirect = Redirect.find_by_from_path(@path)
      redirect_to redirect.to_path
      return
    end
    
    #Get the extentions
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
        return
      end    
    end
    
    #Last, but not least, try to render a page for this path
    set_page_mode
    if logged_in?
      @page = Page.first(:conditions => {:path => @path})
    else
      @page = Page.find_live_by_path(@path)
    end
    
    raise ActiveRecord::RecordNotFound.new("No page at '#{@path}'") unless @page

    if current_user.able_to_view?(@page)
      render :layout => @page.layout
    else
      raise "Access Denied"
    end
    
  end

  private
  def set_page_mode
    @mode = params[:mode] || session[:page_mode] || "view"
    session[:page_mode] = @mode      
  end
  
  
end