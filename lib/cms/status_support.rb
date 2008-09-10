##
#
#
module Cms::StatusSupport

  def self.included(base_class)
    base_class.class_eval do
      base_class.extend ClassMethods
      before_validation_on_create :set_default_status
      validates_inclusion_of :status, :in => STATUSES
      #Metaprogramming FTW :)
      #Define the boolean methods for each status, like published?
      statuses.each do |status|
        define_method "#{status.underscore}?" do
          self.status == status
        end
      end
    end
  end

  module ClassMethods
    def statuses;
      STATUSES
    end

    def status_options
      @statuses ||= statuses.map{|s| [s.titleize, s]}
    end
  end

  IN_PROGRESS = "IN_PROGRESS"
  PUBLISHED = "PUBLISHED"
  ARCHIVED = "ARCHIVED"
  DELETED = "DELETED"
  DEFAULT_STATUS = IN_PROGRESS

  STATUSES = [IN_PROGRESS, PUBLISHED, ARCHIVED, DELETED]



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
      DELETED => :delete
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