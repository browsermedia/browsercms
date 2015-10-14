#
# Guests are a special user that represents a non-logged in user. The main reason to create an explicit
# instance of this type of user is so that the permissions a Guest user can have can be set via the Admin interface.
#
# Every request that a non-logged in user makes will use this User's permissions to determine what they can/can't do.
#
module Cms
  class GuestUser < Cms::User

    include Cms::UsersService::GuestUserModule

    DEFAULT_ATTRIBUTES = {
      login:      Cms::Group::GUEST_CODE,
      first_name: 'Anonymous',
      last_name:  'User'
    }

    def initialize(attributes={})
      super DEFAULT_ATTRIBUTES.merge(attributes)
      @guest = true
    end

  end
end