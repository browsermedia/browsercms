class Group < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_and_belongs_to_many :permissions
  has_and_belongs_to_many :sections
  
  validates_presence_of :name
  
  def editable_by_section?(section)
    cms_user? && sections.find_by_id(section.id)
  end
  
  def cms_user?
    name == 'CMS User'
  end
  
end
