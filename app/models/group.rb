class Group < ActiveRecord::Base
  
  has_many :user_group_memberships
  has_many :users, :through => :user_group_memberships
  
  has_many :group_permissions
  has_many :permissions, :through => :group_permissions
  
  has_many :group_sections
  has_many :sections, :through => :group_sections
  
  belongs_to :group_type
    
  validates_presence_of :name
  
  named_scope :named, lambda{|n| {:conditions => {:name => n}}}
  named_scope :with_code, lambda{|c| {:conditions => {:code => c}}}
    
  named_scope :public, :include => :group_type, :conditions => ["group_types.cms_access = ?", false]
  named_scope :cms_access, :include => :group_type, :conditions => ["group_types.cms_access = ?", true]
  
  def guest?
    group_type && group_type.guest?
  end
  
  def cms_access?
    group_type && group_type.cms_access?
  end
  
end
