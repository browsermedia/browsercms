module Cms

  # A parent class for users that need to be persisted in the CMS database.
  class PersistentUser < ActiveRecord::Base

    include Cms::UsersService.user_compatibility_module

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
        Cms::UsersService.current
      end

      def current=(user)
        Cms::UsersService.current = user
      end

      # Return a GuestUser with the given values.
      def guest(options = {})
        Cms::GuestUser.new(options)
      end
    end

    def group_codes
      groups.map &:code
    end

    def group_codes=(group_codes)
      self.groups = Cms::Group.with_code(group_codes)
    end

    # Determines if this user a Guest or not.
    def guest?
      !!@guest
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

    # This is to show a formatted date on the input form. I'm unsure that
    # this is the best way to solve this, but it works.
    def expires_at_formatted
      expires_at ? (expires_at.strftime '%m/%d/%Y') : nil
    end

  end
end