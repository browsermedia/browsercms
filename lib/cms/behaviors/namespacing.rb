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

  def self.table_prefix
    @table_prefix
  end

  # By setting this, ActiveRecord will automatically prefix all tables in the Cms:: module to start with the value of prefix_
  def self.table_name_prefix
    self.table_prefix
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
    module Namespacing
      extend ActiveSupport::Concern

      module ClassMethods

        # Make this Model use a namespaced table.
        def uses_namespaced_table

        end
      end




    end
  end
end
