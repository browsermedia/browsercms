class Task < ActiveRecord::Base
  belongs_to :assigned_by, :class_name => "User"
  belongs_to :assigned_to, :class_name => "User"
  belongs_to :page
  
  named_scope :complete, :conditions => ["completed_at is not null"]
  named_scope :incomplete, :conditions => ["completed_at is null"]
  
  named_scope :for_page, lambda{|p| {:conditions => {:page => p}}}
  
  validates_presence_of :assigned_by_id, :message => "is required"
  validates_presence_of :assigned_to_id, :message => "is required"
  validate :assigned_by_is_able_to_edit_or_publish_content
  validate :assigned_to_is_able_to_edit_or_publish_content
  
  protected
    def assigned_by_is_able_to_edit_or_publish_content
      if assigned_by && !assigned_by.able_to_edit_or_publish_content?
        errors.add(:assigned_by_id, "cannot assign tasks")
      end
    end

    def assigned_to_is_able_to_edit_or_publish_content
      if assigned_to && !assigned_to.able_to_edit_or_publish_content?
        errors.add(:assigned_to_id, "cannot be assigned tasks")
      end
    end

  
end
