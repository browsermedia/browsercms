#The main reason this module exists is that we need to control the order in which callbacks are define
#and also the call to acts_as_content_object needs to be in the subclasses of AbstractFileBlock
module AttachableTmp
  def self.included(file_block_class)
    file_block_class.class_eval do
    end
  end

  
end