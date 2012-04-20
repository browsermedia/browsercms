module Cms
  class AttachmentsController < Cms::BaseController
    def show
      @attachment = Attachment.find(params[:id])
      @attachment = @attachment.as_of_version(params[:version]) if params[:version]
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