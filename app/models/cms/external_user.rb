module Cms

  # Represents a user that has been authenticated from an external data source. Typical use case might be:
  #
  # ```
  #  # Assumes there is an external Crm tool that we look up username/passwords from.
  #  if(SouthparkCrm::Client.authenticate(params[:login], params[:password]))
  #   user = Cms::ExternalUser.authenticate('stan.marsh', 'southpark-crm')
  #   user.authorize('cms-admin')
  # end
  # ```
  class ExternalUser < Cms::PersistentUser

    # Allows extra data to be cached from external sources without needing to alter table columns of the :cms_users table.
    # This could be anything from security group information to shoe size.
    store :external_data, coder: JSON

    class << self

      # Returns an authenticated external user. If this is the first time this account has been logged in, this will create
      # a new User row as a side effect. Otherwise, it returns the existing user account.
      #
      # @param [String] login
      # @param [String] source Used for documentation purposes to determine where User accounts were granted permission from.
      # @param [Hash] info (Optional) Additional user attributes to assign to user. Can be core user fields (:first_name) or :external_data.
      # @return [Cms::ExternalUser] An ExternalUser record which has been persisted in the database.
      def authenticate(login, source, info={})
        info = work_around_rails_4_serialization_bug(info)
        criteria = {login: login, source: source}
        existing = Cms::ExternalUser.where(criteria).first
        if existing
          existing.update(info)
          return existing
        end
        criteria.merge!(info)
        new_user = Cms::ExternalUser.create!(criteria)
        new_user.groups << Cms::Group.guest if Cms::Group.guest
        new_user
      end

      # Rails 4.0.2 bug: If some value (even {}) for external_data is not specified, then a serialization error occurs.
      def work_around_rails_4_serialization_bug(info)
        {external_data: {}}.merge(info)
      end
    end

    # Determines if this User can have their password changed.
    def password_changeable?
      false
    end

    # Authorize this particular user to be part of one or more groups.
    # This will overwrite any previous group membership. Typically this would be called after authenticating a user.
    # @param [Array<String>] group_codes One or more group codes
    def authorize(*group_codes)
      new_groups = group_codes.collect { |code| Cms::Group.with_code(code).first }
      self.groups = new_groups
    end
  end
end
