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
  named_scope :key_word, lambda { |key_word|
    { :conditions => ["login like :key_word or email like :key_word or first_name like :key_word or last_name like :key_word", {:key_word => "%#{key_word}%"}] }
  }
  named_scope :in_group, lambda { |group_id|
    { :include => :groups, :conditions => ["groups.id = ?", group_id] }
  }

  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) && !u.expired? ? u : nil
  end

  def disable
    self.expires_at = Time.now
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

  def able_to?(name)
    permissions.detect{|p| p.name == name }
  end
  
  def able_to_view?(page)
    groups.count(:conditions => {:group_type => 'CMS User'}) > 0 || viewable_sections.include?(page.section)
  end
  
  def able_to_edit?(section)
    editable_sections.include?(section)
  end
  
end