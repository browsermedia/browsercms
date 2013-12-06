module LoginPortletHelper


  # Acts like this is Cms::Sites::SessionsController
  def controller_name
    'sessions'
  end

  include Cms::Sites::DeviseShimHelper
end