module Cms

  # A parent class for users that need to be persisted in the CMS database.
  class PersistentUser < ActiveRecord::Base

    self.table_name = 'cms_users'

    # Note that Chrome doesn't expire session cookies immediately so test this in other browsers.
    # http://stackoverflow.com/questions/16817229/issues-with-devise-rememberable
    devise :database_authenticatable,
           # Note that Chrome doesn't expire session cookies immediately so test this in other browsers.
           # http://stackoverflow.com/questions/16817229/issues-with-devise-rememberable
           :rememberable,
           :recoverable,  # Needs to be here so forgot password link works.
           :authentication_keys => [:login]


    has_many :user_group_memberships, :class_name => 'Cms::UserGroupMembership', foreign_key: :user_id
    has_many :groups, :through => :user_group_memberships, :class_name => 'Cms::Group', foreign_key: :user_id
    has_many :tasks, :foreign_key => "assigned_to_id", :class_name => 'Cms::Task'

    scope :active, -> { where(["expires_at IS NULL OR expires_at > ?", Time.now.utc]) }
    extend DefaultAccessible


    validates_presence_of :login
    validates_uniqueness_of :login, :case_sensitive => false
    validates_format_of :login, :with => /\A\w[\w\.\-_@]+\z/, :message => "use only letters, numbers, and .-_@ please."

    # Class Methods
    class << self

      def permitted_params
        super + [{:group_ids => []}]
      end

      # Returns all users that can :edit_content or :publish_content permissions.
      #
      # @return [ActiveRelation<Cms::User>] A scope which will find users with the correct permissions.
      def able_to_edit_or_publish_content
        where(["#{Permission.table_name}.name = ? OR #{Permission.table_name}.name = ?", "edit_content", "publish_content"]).includes({:groups => :permissions}).references(:permissions)
      end

      def current
        Thread.current[:cms_user]
      end

      def current=(user)
        Thread.current[:cms_user] = user
      end

      # Return a GuestUser with the given values.
      def guest(options = {})
        Cms::GuestUser.new(options)
      end
    end

    # Determines if this user a Guest or not.
    def guest?
      !!@guest
    end

    # Determines if this user should have access to the CMS administration tools. Can be overridden by specific users (like GuestUser)
    # which may not need to check the database for that information.
    def cms_access?
      groups.cms_access.count > 0
    end

    def disable
      if self.class.where(["expires_at is null and id != ?", id]).count > 0
        self.expires_at = Time.now - 2.minutes
      else
        false
      end
    end

    def disable!
      unless disable
        raise "You must have at least 1 enabled user"
      end
      save!
    end

    # Determines if this user should be authenticated. Hook for Devise.
    #
    # @override Devise::Models::Authenticatable#active_for_authentication?
    # @return [Boolean] true if this user has not expired.
    def active_for_authentication?
      is_active = !expired?
      logger.error "Expired User '#{login}' failed to login. Account expired on #{expires_at_formatted}." unless is_active
      is_active
    end

    # Determines if this User can have their password changed.
    def password_changeable?
      true
    end

    # Determines if this user has expired or has been disabled.
    # @return [Boolean]
    def expired?
      expires_at && expires_at <= Time.now
    end

    def enable
      self.expires_at = nil
    end

    def enable!
      enable
      save!
    end

    def full_name
      [first_name, last_name].reject { |e| e.nil? }.join(" ")
    end

    def full_name_with_login
      "#{full_name} (#{login})"
    end

    def full_name_or_login
      if full_name.strip.blank?
        login
      else
        full_name
      end
    end

    # This is to show a formated date on the input form. I'm unsure that
    # this is the best way to solve this, but it works.
    def expires_at_formatted
      expires_at ? (expires_at.strftime '%m/%d/%Y') : nil
    end

    def permissions
      @permissions ||= Cms::Permission.where(["#{self.class.table_name}.id = ?", id]).includes({:groups => :users}).references(:users)
    end

    def viewable_sections
      @viewable_sections ||= Cms::Section.where(["#{self.class.table_name}.id = ?", id]).includes(:groups => :users).references(:users)
    end

    def modifiable_sections
      @modifiable_sections ||= Cms::Section.where(["#{self.class.table_name}.id = ? and #{GroupType.table_name}.cms_access = ?", id, true]).includes(:groups => [:group_type, :users]).references(:users, :groups)
    end

    # Expects a list of names of Permissions
    # true if the user has any of the permissions
    def able_to?(*required_permissions)
      perms = required_permissions.map(&:to_sym)
      permissions.any? do |p|
        perms.include?(p.name.to_sym)
      end
    end

    # Determine if this user has permission to view the specific object. Permissions
    #   are always tied to a specific section. This method can take different input parameters
    #   and will attempt to determine the relevant section to check.
    # Expects object to be of type:
    #   1. Section - Will check the user's groups to see if any of those groups can view this section.
    #   2. Path - Will look up the section based on the path, then check it.  (Note that section paths are not currently unique, so this will check the first one it finds).
    #   3. Other - Assumes it has a section attribute and will call that and check the return value.
    #
    # Returns: true if the user can view this object, false otherwise.
    # Raises: ActiveRecord::RecordNotFound if a path to a not existent section is passed in.
    def able_to_view?(object)
      section = object
      if object.is_a?(String)
        section = Cms::Section.find_by_path(object)
        raise ActiveRecord::RecordNotFound.new("Could not find section with path = '#{object}'") unless section
      elsif !object.is_a?(Cms::Section)
        section = object.parent
      end
      viewable_sections.include?(section) || cms_access?
    end

    def able_to_modify?(object)
      case object
        when Cms::Section
          modifiable_sections.include?(object)
        when Cms::Page, Cms::Link
          modifiable_sections.include?(object.section)
        else
          if object.class.respond_to?(:connectable?) && object.class.connectable?
            object.connected_pages.all? { |page| able_to_modify?(page) }
          else
            true
          end
      end
    end

    # Expects node to be a Section, Page or Link
    # Returns true if the specified node, or any of its ancestor sections, is editable by any of
    # the user's 'CMS User' groups.
    def able_to_edit?(object)
      able_to?(:edit_content) && able_to_modify?(object)
    end

    def able_to_publish?(object)
      able_to?(:publish_content) && able_to_modify?(object)
    end

    def able_to_edit_or_publish_content?
      able_to?(:edit_content, :publish_content)
    end

  end
end