class Page
  
  IN_PROGRESS = "IN_PROGRESS"
  PUBLISHED = "PUBLISHED"
  HIDDEN = "HIDDEN"
  ARCHIVED = "ARCHIVED"
  DELETED = "DELETED"
  
  DEFAULT_STATUS = IN_PROGRESS
  
  STATUSES = [IN_PROGRESS, PUBLISHED, HIDDEN, ARCHIVED, DELETED]
  
  before_validation_on_create :set_default_status
  
  validates_inclusion_of :status, :in => STATUSES

  class << self
    def statuses; STATUSES end
    def status_options
      @statuses ||= statuses.map{|s| [s.titleize, s]}
    end
  end

  def set_default_status
    self.status = DEFAULT_STATUS if status.blank?
  end
  
  def status_name
    status.titleize
  end
  
  #Metaprogramming FTW :)
  #Define the boolean methods for each status, like published?
  statuses.each do |status|
    define_method "#{status.underscore}?" do
      self.status == status
    end
  end
  
  { #Define the action methods for each status, like publish and publish!, which set the status and call save
    PUBLISHED => :publish,
    HIDDEN => :hide,
    ARCHIVED => :archive
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
    
  def delete!
    self.status = DELETED
    save!
  end  
    
end