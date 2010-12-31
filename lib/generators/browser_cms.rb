require 'rails/generators/base'

module BrowserCms
  module Generators
    class Base < Rails::Generators::Base
      def self.source_root
        @_browsercms_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), '../../'))
        # ["./", "public/javascripts"]
      end
    end
  end
end