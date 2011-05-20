#
# Guests are a special user that represents a non-logged in user. The main reason to create an explicit
# instance of this type of user is so that the permissions a Guest user can have can be set via the Admin interface.
#
# Every request that a non-logged in user makes will use this User's permissions to determine what they can/can't do.
#
module Cms
  class GuestUser < Cms::User

    def initialize(attributes={})
      super({:login => Cms::Group::GUEST_CODE, :first_name => "Anonymous", :last_name => "User"}.merge(attributes))
      @guest = true
    end

    def able_to?(*name)
      group && group.permissions.count(:conditions => ["name in (?)", name.map(&:to_s)]) > 0
    end

    # Guests never get access to the CMS.
    # Overridden from user so that able_to_view? will work correctly.
    def cms_access?
      false
    end

    # Return a list of the sections associated with this user that can be viewed.
    # Overridden from user so that able_to_view? will work correctly.
    def viewable_sections
      group.sections
    end

    def able_to_edit?(section)
      false
    end

    def group
      @group ||= Cms::Group.guest
    end

    def groups
      [group]
    end

    #You shouldn't be able to save a guest user
    def update_attribute(name, value)
      false
    end

    def update_attributes(attrs={})
      false
    end

    def save(perform_validation=true)
      false
    end

  end
end