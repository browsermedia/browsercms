class ActiveRecord::Base
  class << self
    def content_block_type
      to_s.underscore
    end
  end
end