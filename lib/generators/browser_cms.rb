require 'rails/generators/base'

module BrowserCms
  module Generators
    # Base class for generators that work on copying files out of the Gem into projects.
    class Base < Rails::Generators::Base
      def self.source_root
        @_browsercms_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), '../../'))
      end
    end
  end
end