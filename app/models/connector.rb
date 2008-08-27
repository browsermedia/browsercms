class Connector < ActiveRecord::Base
  belongs_to :page
  belongs_to :content_block, :polymorphic => true
  
  validates_presence_of :container
  
  named_scope :for_block, lambda {|b| {:conditions => ['connectors.content_block_id = ? and connectors.content_block_type = ?', b.id, b.class.name]}}
  
end