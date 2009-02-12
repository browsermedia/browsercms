require 'digest/sha1'

class User < ActiveRecord::Base
  include Cms::Authentication::Model

  validates_presence_of     :login
  #validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login,    :case_sensitive => false
  validates_format_of       :login,    :with => /\A\w[\w\.\-_@]+\z/, :message => "use only letters, numbers, and .-_@ please."

  validates_presence_of     :email
  #validates_length_of       :email,    :within => 6..100 #r@a.wk
  #validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => /[^@]{2,}@[^.]{2,}\..{2,}/, :message => "should be an email address, ex. xx@xx.com"

  attr_accessible :login, :email, :name, :first_name, :last_name, :password, :password_confirmation, :expires_at

  has_many :user_group_memberships
  has_many :groups, :through => :user_group_memberships
  has_many :tasks, :foreign_key => "assigned_to_id"
    
  named_scope :active, :conditions => {:expires_at => nil }
  named_scope :able_to_edit_or_publish_content, 
    :include => {:groups => :permissions}, 
    :conditions => ["permissions.name = ? OR permissions.name = ?", "edit_content", "publish_content"]

  def self.current
    Thread.current[:cms_user]
  end
  def self.current=(user)
    Thread.current[:cms_user] = user
  end
    
  def self.guest(options = {})
    GuestUser.new(options)
  end

  def guest?
    !!@guest
  end

  def disable
    if self.class.count(:conditions => ["expires_at is null and id != ?", id]) > 0
      self.expires_at = Time.now - 1.minutes
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
    [first_name, last_name].reject{|e| e.nil?}.join(" ")
  end

  def full_name_with_login
    "#{full_name} (#{login})"
  end

  # This is to show a formated date on the input form. I'm unsure that
  # this is the best way to solve this, but it works.
  def expires_at_formatted
    expires_at ? (expires_at.strftime '%m/%d/%Y' ): nil
  end

  def permissions
    @permissions ||= Permission.find(:all, :include => {:groups => :users}, :conditions => ["users.id = ?", id])
  end

  def viewable_sections
    @viewable_sections ||= Section.find(:all, :include => {:groups => :users}, :conditions => ["users.id = ?", id])
  end

  def editable_sections
    @editable_sections ||= Section.find(:all, :include => {:groups => [:group_type, :users]}, :conditions => ["users.id = ? and group_types.cms_access = ?", id, true])
  end

  #Expects a list of names of Permissions
  #true if the user has any of the permissions
  def able_to?(*required_permissions)
    perms = required_permissions.map(&:to_sym)
    permissions.any? do |p| 
      perms.include?(p.name.to_sym) 
    end
  end
    
  #Expects object to be an object or a section
  #If it's a section, that will be used
  #If it's not a section, it will call section on the object
  #returns true if any of the sections of the groups the user is in matches the page's section.
  def able_to_view?(object)
    section = object.is_a?(Section) ? object : object.section
    !!(viewable_sections.include?(section) || groups.cms_access.count > 0)
  end
  
  #Expects section to be a Section
  #Returns true if any of the sections of the groups that have group_type = 'CMS User' 
  #that the user is in match the section.
  def able_to_edit?(section)    
    !!(editable_sections.include?(section) && able_to?(:edit_content))
  end
  
  def able_to_edit_or_publish_content?
    able_to?(:edit_content, :publish_content)
  end
  
end