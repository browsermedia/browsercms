module Cms
  class AttachmentsController < Cms::BaseController

    skip_before_filter :redirect_to_cms_site, :only => [:download]
    skip_before_filter :login_required, :only => [:download]
    skip_before_filter :cms_access_required, :only => [:download]

    include Cms::ContentRenderingSupport

    def show
      @attachment = Attachment.find(params[:id])
      @attachment = @attachment.as_of_version(params[:version]) if params[:version]
      send_file(@attachment.full_file_location,
                :filename => @attachment.file_name,
                :type => @attachment.file_type,
                :disposition => "inline"
      )
    end

    # This handles serving files for attachments that don't have a user specified path. If a path is defined,
    # the ContentController#try_to_stream will handle it.
    #
    # Users can only download files if they have permission to view it.
    def download
      @attachment = Attachment.find(params[:id])

      raise Cms::Errors::AccessDenied unless current_user.able_to_view?(@attachment)

      send_file(@attachment.full_file_location,
                :filename => @attachment.file_name,
                :type => @attachment.file_type,
                :disposition => "inline"
      )
    end

    def create
      @attachment = Attachment.new(params[:attachment])
      @attachment.published = true
      if @attachment.save
        render :partial => 'cms/attachments/attachment_wrapper', :locals => {:attachment => @attachment}
      else
        #TODO: render html error string
        render :inline => 'an error ocurred'
      end
    end

    def destroy
      @attachment = Attachment.find(params[:id])
      @attachment.destroy
      render :json => @attachment.id
    end
  end
end