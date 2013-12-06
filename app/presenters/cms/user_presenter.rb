module Cms

  # Wrap User for JSON formatting.
  class UserPresenter

    attr_reader :resource

    def initialize(user)
      @resource = user
    end

    def as_json(options)
      hash = resource.as_json(
          :only => [:id, :email, :login, :first_name, :last_name],
          :methods => [:full_name])
      hash[:is_logged_in] = logged_in?
      hash
    end

    def logged_in?
      !@resource.guest?
    end
  end
end