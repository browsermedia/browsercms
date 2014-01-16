module Cms
  class AttachmentsController < Cms::BaseController

    allow_guests_to [:download]

    include ContentRenderingSupport
    include Cms::Attachments::Serving

    # Returns a specific version of an attachment.
    # Used to display older versions in the editor interface.
    def show
      @attachment = Attachment.unscoped.find(params[:id])
      @attachment = @attachment.as_of_version(params[:version]) if params[:version]
      send_attachment(@attachment)
    end

    # This handles serving files for attachments that don't have a user specified path. If a path is defined,
    # the ContentController#try_to_stream will handle it.
    #
    # Users can only download files if they have permission to view it.
    def download
      @attachment = Attachment.find(params[:id])
      send_attachment(@attachment)
    end

    def create
      @attachment = Attachment.new(permitted_params())
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

    private
    def permitted_params
      params.require(:attachment).permit(Attachment.permitted_params)
    end
  end
end