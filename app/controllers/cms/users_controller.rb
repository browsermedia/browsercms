class Cms::UsersController < Cms::ResourceController
  layout 'cms/administration'
  
  after_filter :update_group_membership, :only => [:update, :create]
  after_filter :update_flash, :only => :update
  
  def index
    query, conditions = [], []
    
    unless params[:show_expired]
      query << "expires_at IS NULL OR expires_at > ?"
      conditions << Time.now
    end

    unless params[:key_word].blank?
      query << %w(login email first_name last_name).collect { |f| "#{f} LIKE ?" }.join(" OR ")
      4.times { conditions << "%#{params[:key_word]}%" }
    end
    
    unless params[:group_id].to_i == 0
      query << "user_group_memberships.group_id = ?"
      conditions << params[:group_id]
    end
    
    query.collect! { |q| "(#{q})"}
    conditions = conditions.unshift(query.join(" AND "))
    per_page = params[:per_page] || 10
    
    @users = User.paginate(:page => params[:page], :per_page => per_page, :include => :user_group_memberships, :conditions => conditions)
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

    def update_flash
      flash[:notice] = "Password for '#{@object.login}' changed" if params[:on_fail_action] == "change_password"
    end

    def update_group_membership
      @object.group_ids = params[:group_ids] unless params[:on_fail_action] == "change_password"
    end

  private
    def user
      @user ||= User.find(params[:id])
    end
end
