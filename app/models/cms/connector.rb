class Connector < ActiveRecord::Base
  belongs_to :page
  belongs_to :connectable, :polymorphic => true
  
  acts_as_list :scope => 'connectors.page_id = #{page_id} and connectors.page_version = #{page_version} and connectors.container = \'#{container}\''
  alias :move_up :move_higher 
  alias :move_down :move_lower  
  
  named_scope :for_page_version, lambda{|pv| {:conditions => {:page_version => pv}}}
  named_scope :for_connectable_version, lambda{|cv| {:conditions => {:connectable_version => cv}}}
  named_scope :for_connectable, lambda{|c| 
    {:conditions => { :connectable_id => c.id, :connectable_type => c.class.base_class.name }}
  }  
  named_scope :in_container, lambda{|container| {:conditions => {:container => container}}}
  named_scope :at_position, lambda{|position| {:conditions => {:position => position}}}  
  named_scope :like, lambda{|connector|
    {:conditions => { 
      :connectable_id => connector.connectable_id, 
      :connectable_type => connector.connectable_type,
      :connectable_version => connector.connectable_version,
      :container => connector.container,
      :position => connector.position
    }}
  }
  
  validates_presence_of :page_id, :page_version, :connectable_id, :connectable_type, :container
  
  def current_connectable
    if versioned?
      connectable.as_of_version(connectable_version) if connectable
    else
      get_connectable
    end
  end
  
  def connectable_with_deleted
    c = if connectable_type.constantize.respond_to?(:find_with_deleted)
      connectable_type.constantize.find_with_deleted(connectable_id)
    else
      connectable_type.constantize.find(connectable_id)
    end
    (c && c.class.versioned?) ? c.as_of_version(connectable_version) : c
  end
  
  def status
    live? ? 'published' : 'draft'
  end        

  def status_name
    status.to_s.titleize
  end  
  
  def live?
    if publishable?
      connectable.live?
    else
      true
    end
  end
  
  def publishable?
    connectable_type.constantize.publishable?
  end
  
  def versioned?
    connectable_type.constantize.versioned?
  end

  # Determines if a connector should be copied when a page is updated/versioned, etc.
  #
  # 
  def should_be_copied?
    if connectable && (!connectable.respond_to?(:draft) || !connectable.draft.deleted?)
      return true
    end


    false
  end
end