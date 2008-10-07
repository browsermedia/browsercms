class Cms::UsersController < Cms::ResourceController
  layout 'cms/administration'
  
  def index
    @users = User.find(:all)
  end

  def change_password
    user
  end

  def disable
    user.disable!
    redirect_to :action => "index"
  end
  
  def enable
    user.enable!
    redirect_to :action => "index"
  end

  protected
    def after_create_url
      index_url
    end

    def after_update_url
      index_url
    end

  private
    def user
      @user ||= User.find(params[:id])
    end
end
