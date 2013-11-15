module Cms

  # @deprecated To be removed in BrowserCMS 4.1 or later.
  def self.table_prefix=(prefix)
    message = "Calling Cms.table_prefix('#{prefix}') is no longer necessary and can be removed from your project. See https://github.com/browsermedia/browsercms/issues/639"
    ActiveSupport::Deprecation.warn(message, caller(1))
  end

  module Behaviors
    module Namespacing


    end
  end
end