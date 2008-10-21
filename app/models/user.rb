require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  validates_presence_of     :login
  #validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login,    :case_sensitive => false
  validates_format_of       :login,    :with => RE_LOGIN_OK, :message => MSG_LOGIN_BAD

  validates_presence_of     :email
  #validates_length_of       :email,    :within => 6..100 #r@a.wk
  #validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD

  attr_accessible :login, :email, :name, :first_name, :last_name, :password, :password_confirmation, :expires_at

  has_many :user_group_memberships
  has_many :groups, :through => :user_group_memberships
    
  named_scope :active, :conditions => {:expires_at => nil }

  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) && !u.expired? ? u : nil
  end
  
  def can_login?
    self.class.find_by_login(login, :include => { :groups => :permissions }, :conditions => ["permissions.name in (?)", %w(cms-administrator editor publish-page)])
  end
  
  def self.guest(options = {})
    GuestUser.new(options)
  end

  def guest?
    !!@guest
  end

  def disable
    self.expires_at = Time.now - 1.minutes
  end

  def disable!
    disable
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
    @editable_sections ||= Section.find(:all, :include => {:groups => :users}, :conditions => ["users.id = ? and groups.group_type = 'CMS User'", id])
  end

  #Expects name to be the name of a Permission
  #Return the Permission that matches that name 
  #one of the groups the user is in has that permission
  #Otherwise returns nil
  def able_to?(name)
    permissions.detect{|p| p.name == name }
  end
  
  #Expects object to be an object or a section
  #If it's a section, that will be used
  #If it's not a section, it will call section on the object
  #returns true if any of the sections of the groups the user is in matches the page's section.
  def able_to_view?(object)
    section = object.is_a?(Section) ? object : object.section
    !!(viewable_sections.include?(section) || groups.cms.count > 0)
  end
  
  #Expects section to be a Section
  #Returns true if any of the sections of the groups that have group_type = 'CMS User' 
  #that the user is in match the section.
  def able_to_edit?(section)
    !!(editable_sections.include?(section))
  end
  
end