class Cms::UsersController < Cms::ResourceController
  layout 'cms/administration'
  
  def index
    @users = User.find(:all)
  end

  def change_password
    @user = User.find(params[:id])
    @change_password = true
  end
  protected
    def after_create_url
      index_url
    end

    def after_update_url
      index_url
    end
end
