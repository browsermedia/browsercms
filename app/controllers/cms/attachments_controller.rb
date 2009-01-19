class Cms::AttachmentsController < Cms::BaseController
  def show
    @attachment = Attachment.find(params[:id])
    @attachment = @attachment.as_of_version(params[:version]) if params[:version]
    send_file(@attachment.full_file_location, 
      :filename => @attachment.file_name,
      :type => @attachment.file_type,
      :disposition => "inline"
    )     
  end
end