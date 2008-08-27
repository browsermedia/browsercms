module BlockSupport


  def content_block_type
    self.class.content_block_type
  end
  def content_block_label
    self.class.content_block_label
  end
  module ClassMethods
    def content_block_type
      to_s.underscore
    end
    def content_block_label
      to_s.titleize
    end
  end

  def self.included(base_class)
    base_class.send(:extend, ClassMethods)
  end
end