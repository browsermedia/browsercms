module Cms
  class HomeController < Cms::BaseController

    # Only occurs if somebody goes to /cms, they get redirected to /
    # However, based on whether they are an admin or not, it will determine where they get sent.
    def index
      redirect_to '/'
    end
  end
end