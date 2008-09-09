##
#
#
module Cms::StatusSupport

  def self.included(base_class)
    base_class.class_eval do
      before_validation_on_create :set_default_status
    end
  end

  IN_PROGRESS = "IN_PROGRESS"
  PUBLISHED = "PUBLISHED"
  ARCHIVED = "ARCHIVED"
  DEFAULT_STATUS = IN_PROGRESS

  # blocks can't be hidden
  # HIDDEN = "HIDDEN"

  def set_default_status
    self.status = DEFAULT_STATUS if status.blank?
  end

  #Define the action methods for each status, like publish and publish!, which set the status and call save
  {
      PUBLISHED => :publish,
      ARCHIVED => :archive,
      IN_PROGRESS => :in_progress,
  }.each do |status, method_name|
    define_method method_name do
      self.status = status
      save
    end
    define_method "#{method_name}!" do
      self.status = status
      save!
    end
  end


end