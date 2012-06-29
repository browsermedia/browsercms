module Cms
  class EmailMessagesController < Cms::BaseController

    include Cms::AdminTab

    check_permissions :administrate

    def index
      @messages = EmailMessage.paginate(:page => params[:page])
    end

    def show
      @message = EmailMessage.find(params[:id])
    end

    private
    def set_menu_section
      @menu_section = 'email_messages'
    end
  end
end