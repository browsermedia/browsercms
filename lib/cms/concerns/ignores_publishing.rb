# Allows content types (like Category) to be handled as blocks.
# Intended as temporary
module Cms::Concerns::IgnoresPublishing

  # Needs due to content controller automatically setting a default 'publish_on_save: false' when creating content.
  def self.included(klass)
    klass.send :attr_accessor, :publish_on_save
    klass.attr_accessible :publish_on_save
  end
end