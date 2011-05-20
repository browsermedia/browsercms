class LoginPortlet < Cms::Portlet
  
  def render
    @success_url = (flash[:success_url] || self.success_url)
    @failure_url = self.failure_url
    @login = flash[:login] || params[:login]
    @remember_me = flash[:remember_me] || params[:remember_me]
  end
    
end
