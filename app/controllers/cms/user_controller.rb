module Cms
  class UserController < Cms::ApplicationController
    # Return information about the current user as json. Can be used by cached html pages do create interactive elements.
    def show
      render json: Cms::UserPresenter.new(current_user)
    end
  end
end
