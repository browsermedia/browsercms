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

  has_and_belongs_to_many :groups

  named_scope :active, :conditions => {:expires_at => nil }
  named_scope :key_word, lambda { |key_word|
    { :conditions => ["login like :key_word or email like :key_word or first_name like :key_word or last_name like :key_word", {:key_word => "%#{key_word}%"}] }
  }
  named_scope :in_group, lambda { |group_id|
    { :joins => " left outer join groups_users on users.id = groups_users.user_id join groups on groups_users.group_id = groups.id ", :conditions => ["groups.id = ?", group_id] }
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

  # TODO: Could probably be written in a more Railsy fashion.
  # This will result in a few too many database look ups as well.
  # Should eager load permissions to avoid N+1 problem.
  def has_permission(name)
    groups.each do |g|
      g.permissions.each do |p|
        return true if p.name == name
      end
    end
    false
  end
end