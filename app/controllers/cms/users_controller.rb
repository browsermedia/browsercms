class Cms::UsersController < Cms::ResourceController
  layout 'cms/administration'
  
  after_filter :update_group_membership, :only => [:update, :create]
  
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

    def update_group_membership
      @object.group_ids = params[:group_ids] unless params[:on_fail_action] == "change_password"
    end

  private
    def user
      @user ||= User.find(params[:id])
    end
end
