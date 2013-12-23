#
# A group represents a collection of permissions. Each User can be assigned to one or more groups, and the sum of
# their permissions from all groups combined represents what they can do.
#
class Cms::Group < ActiveRecord::Base
  GUEST_CODE = "guest"

  has_many :user_group_memberships, :class_name => 'Cms::UserGroupMembership'
  has_many :users, :through => :user_group_memberships, :class_name => 'Cms::PersistentUser'

  has_many :group_permissions, :class_name => 'Cms::GroupPermission'
  has_many :permissions, :through => :group_permissions, :class_name => 'Cms::Permission'

  has_many :group_sections, :class_name => 'Cms::GroupSection'
  has_many :sections, :through => :group_sections, :class_name => 'Cms::Section'

  belongs_to :group_type, :class_name => 'Cms::GroupType'

  extend Cms::DefaultAccessible

  # @override Add extra params
  def self.permitted_params
    super + [:group_type_id] +[section_ids: [], permission_ids: []]
  end


  validates_presence_of :name

  class << self
    def named(n)
      where name: n
    end

    def with_code(c)
      where code: c
    end
  end

  scope :public, -> { where(["#{Cms::GroupType.table_name}.cms_access = ?", false]).includes(:group_type).references(:group_type) }
  scope :cms_access, -> { where(["#{Cms::GroupType.table_name}.cms_access = ?", true]).includes(:group_type).references(:group_type) }

  def guest?
    group_type && group_type.guest?
  end

  def cms_access?
    group_type && group_type.cms_access?
  end

  # Finds the guest group, which is a special group that represents public non-logged in users.
  def self.guest
    with_code(GUEST_CODE).first
  end


  def has_permission?(permission)
    permissions.any? do |p|
      return true if permission.to_sym == p.name.to_sym
    end
    false
  end
end
