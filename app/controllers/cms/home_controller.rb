module Cms
  class HomeController < Cms::BaseController
    def index
      redirect_to '/'
    end
  end
end