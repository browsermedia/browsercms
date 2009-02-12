class Task < ActiveRecord::Base
  belongs_to :assigned_by, :class_name => "User"
  belongs_to :assigned_to, :class_name => "User"
  belongs_to :page
  
  after_create :mark_other_tasks_for_the_same_page_as_complete
  after_create :send_email
  
  named_scope :complete, :conditions => ["completed_at is not null"]
  named_scope :incomplete, :conditions => ["completed_at is null"]
  
  named_scope :for_page, lambda{|p| {:conditions => ["page_id = ?", p]}}
  named_scope :other_than, lambda{|t| {:conditions => ["id != ?", t.id]}}
  
  validates_presence_of :assigned_by_id, :message => "is required"
  validates_presence_of :assigned_to_id, :message => "is required"
  validates_presence_of :page_id, :message => "is required"
  validate :assigned_by_is_able_to_edit_or_publish_content
  validate :assigned_to_is_able_to_edit_or_publish_content
  
  def mark_as_complete!
    update_attributes(:completed_at => Time.now)
  end
  
  def completed?
    !!completed_at
  end
  
  protected
    def mark_other_tasks_for_the_same_page_as_complete
      self.class.other_than(self).incomplete.all.each do |t|
        t.mark_as_complete!
      end
    end
  
    def send_email
      #Hmm... what if the assign_by or assign_to don't have email addresses?
      #For now we'll say just don't send an email and log that as a warning
      if assigned_by.email.blank?
        logger.warn "Can't send email for task because assigned by user #{assigned_by.login}:#{assigned_by.id} has no email address"
      elsif assigned_to.email.blank?
        logger.warn "Can't send email for task because assigned to user #{assigned_to.login}:#{assigned_to.id} has no email address"
      else
        email = EmailMessage.create(
          :sender => assigned_by.email,
          :recipients => assigned_to.email,
          :subject => "Page '#{page.name}' has been assigned to you",
          :body => "http://#{SITE_DOMAIN}#{page.path}\n\n#{comment}"
        )
      end
      true #don't accidently return false and halt the chain
    end
  
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
