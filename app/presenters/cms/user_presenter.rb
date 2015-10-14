module Cms

  # Wrap User for JSON formatting.
  class UserPresenter

    attr_reader :resource

    def initialize(user)
      @resource = user
    end

    def as_json(_options = nil)
      basic_hash.merge Cms.user_key_field.to_sym  => login,
                       Cms.user_name_field.to_sym => full_name
    end

    def basic_hash
      {
        id:           id,
        login:        login,
        full_name:    full_name,
        is_logged_in: logged_in?,
        guest:        guest?,
      }
    end

    def full_name
      resource.send Cms.user_name_field
    end

    def login
      resource.send Cms.user_key_field
    end

    def id
      resource.try :id
    end

    def guest?
      resource.guest?
    end

    def logged_in?
      !guest?
    end
  end
end