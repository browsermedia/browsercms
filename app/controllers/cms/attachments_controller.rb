module Cms
  class AttachmentsController < Cms::BaseController

    before_filter :redirect_to_cms_site, :only => [:download]
    before_filter :login_required, :only => [:download]
    before_filter :cms_access_required, :only => [:download]

    def show
      @attachment = Attachment.find(params[:id])
      @attachment = @attachment.as_of_version(params[:version]) if params[:version]
      send_file(@attachment.full_file_location,
                :filename => @attachment.file_name,
                :type => @attachment.file_type,
                :disposition => "inline"
      )
    end

    # This will handle serving files that don't have custom paths
    # Security should match how ContentController#try_to_send_file works
    def download
      @attachment = Attachment.find(params[:id])
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