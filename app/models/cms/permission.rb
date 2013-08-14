module Cms
  class Permission < ActiveRecord::Base

   #attr_accessible :name, :full_name, :description

    has_many :group_permissions, :class_name => 'Cms::GroupPermission'
    has_many :groups, :through => :group_permissions, :class_name => 'Cms::Group'

    validates_presence_of :name
    validates_uniqueness_of :name

    def self.named(name)
      where(name: name)
    end

  end
end