module Cms

  # Represents a CMS users that is managed through the CMS UI.
  class User < PersistentUser
    include Devise::Models::Validatable
    include Devise::Models::Recoverable

    class << self
      # Change a given user's password.
      #
      # @param [String] login
      # @param [String] new_password
      def change_password(login, new_password)
        find_by_login(login).change_password(new_password)
      end

      def permitted_params
        super + [:password, :password_confirmation]
      end
    end

    # Change this User's password to a new value.
    def change_password(new_password)
      update(:password => new_password, :password_confirmation => new_password)
    end
  end
end