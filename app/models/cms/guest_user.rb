#
# Guests are a special user that represents a non-logged in user. The main reason to create an explicit
# instance of this type of user is so that the permissions a Guest user can have can be set via the Admin interface.
#
# Every request that a non-logged in user makes will use this User's permissions to determine what they can/can't do.
#
module Cms
  class GuestUser < Cms::User

    include Cms::UsersService::GuestUserModule

    def initialize(attributes={})
      super({:login => Cms::Group::GUEST_CODE, :first_name => "Anonymous", :last_name => "User"}.merge(attributes))
      @guest = true
    end

  end
end