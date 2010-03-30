module Cms
class EmailMessagesController < Cms::BaseController
  layout 'cms/administration'
  
  check_permissions :administrate
  
  def index
    @messages = EmailMessage.paginate(:page => params[:page])
  end
  
  def show
    @message = EmailMessage.find(params[:id])
  end
  
end
end