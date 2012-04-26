require 'digest/sha1'

module Cms
  class User < ActiveRecord::Base

    include Cms::Authentication::Model

    validates_presence_of :login
    #validates_length_of       :login,    :within => 3..40
    validates_uniqueness_of :login, :case_sensitive => false
    validates_format_of :login, :with => /\A\w[\w\.\-_@]+\z/, :message => "use only letters, numbers, and .-_@ please."

    validates_presence_of :email
    #validates_length_of       :email,    :within => 6..100 #r@a.wk
    #validates_uniqueness_of   :email,    :case_sensitive => false
    validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "should be an email address, ex. xx@xx.com"
    attr_accessible :login, :email, :name, :first_name, :last_name, :password, :password_confirmation, :expires_at

    has_many :user_group_memberships, :class_name => 'Cms::UserGroupMembership'
    has_many :groups, :through => :user_group_memberships, :class_name => 'Cms::Group'
    has_many :tasks, :foreign_key => "assigned_to_id", :class_name => 'Cms::Task'

    scope :active, :conditions => ["expires_at IS NULL OR expires_at > ?", Time.now.utc]
    scope :able_to_edit_or_publish_content,
          :include => {:groups => :permissions},
          :conditions => ["#{Permission.table_name}.name = ? OR #{Permission.table_name}.name = ?", "edit_content", "publish_content"]

    def self.current
      Thread.current[:cms_user]
    end

    def self.current=(user)
      Thread.current[:cms_user] = user
    end

    def self.guest(options = {})
      Cms::GuestUser.new(options)
    end

    def guest?
      !!@guest
    end

    # Determines if this user should have access to the CMS administration tools. Can be overridden by specific users (like GuestUser)
    # which may not need to check the database for that information.
    def cms_access?
      groups.cms_access.count > 0
    end

    def disable
      if self.class.count(:conditions => ["expires_at is null and id != ?", id]) > 0
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
      @permissions ||= Cms::Permission.find(:all, :include => {:groups => :users}, :conditions => ["#{User.table_name}.id = ?", id])
    end

    def viewable_sections
      @viewable_sections ||= Cms::Section.find(:all, :include => {:groups => :users}, :conditions => ["#{User.table_name}.id = ?", id])
    end

    def modifiable_sections
      @modifiable_sections ||= Cms::Section.find(:all, :include => {:groups => [:group_type, :users]}, :conditions => ["#{Cms::User.table_name}.id = ? and #{GroupType.table_name}.cms_access = ?", id, true])
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
        section = object.section
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