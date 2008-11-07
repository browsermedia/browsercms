class Connector < ActiveRecord::Base
  belongs_to :page
  
  #Can't use just 'block', because 'block_type' is used by rails
  belongs_to :content_block, :polymorphic => true

  acts_as_list :scope => 'connectors.page_id = #{page_id} and connectors.page_version = #{page_version} and connectors.container = \'#{container}\''
  alias :move_up :move_higher 
  alias :move_down :move_lower 
  
  validates_presence_of :container
  
  named_scope :for_block, lambda {|b| {:conditions => ['connectors.content_block_id = ? and connectors.content_block_type = ?', b.id, b.class.name]}}
  named_scope :for_container, lambda{|container| {:conditions => ['connectors.container = ?', container]} }

  #Returns the content block that this connector is connected to
  def content_block
    @__content_block__ ||= begin
      if content_block_type.constantize.respond_to?(:versioned_class_name)
        b = content_block_type.constantize.first(:conditions => {:id => content_block_id, :version => content_block_version})
    
        #If this connector is referring to an older version of the block, we have to look in the versions table
        b ? b : content_block_type.constantize.find(content_block_id).as_of_version(content_block_version)
      else
        content_block_type.constantize.find(content_block_id)
      end
    end
  end
  
end