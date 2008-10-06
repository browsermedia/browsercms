class Cms::UsersController < Cms::ResourceController
  layout 'cms/administration'
  
  def index
    @users = User.find(:all)
  end

  protected
    def after_create_url
      index_url
    end

end
