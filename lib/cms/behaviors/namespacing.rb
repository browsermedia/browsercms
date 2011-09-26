module Cms

  # Provides a global configuration setting to set a table prefix for all CMS tables.
  #
  # For example, Cms.table_prefix = "cms_" would create tables like:
  #   cms_html_blocks cms_pages
  # rather than
  #   html_blocks pages
  #
  def self.table_prefix=(prefix)
    @table_prefix = prefix
  end


  # Returns the table name prefix for models in the Cms:: Namespace
  # Prefer calling table_name_prefix to this methods
  # @return [String] nil if no namespace has been set.
  #
  def self.table_prefix
    @table_prefix
  end

  # By setting this, ActiveRecord will automatically prefix all tables in the Cms:: module to start with the value of prefix_
  # Defaults to "" if not specified.
  def self.table_name_prefix
    self.table_prefix ? self.table_prefix : ""
  end

  module Namespacing

    def self.prefixed_table_name(unprefixed_name)
      "#{Cms.table_prefix}#{unprefixed_name}"
    end
    def self.prefix(unprefixed_name)
      self.prefixed_table_name(unprefixed_name)
    end
  end

  module Behaviors
    # Noop - This will be automatically included on all ActiveRecord classes. I don't want to move this, so
    # I'm leaving it as a harmless NOOP for now.
    module Namespacing
    end
  end
end
