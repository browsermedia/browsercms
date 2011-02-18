module Cms
  module Generators
    class UpgradeModuleGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      class_option :prep, :default=>false, :type=>:boolean, :desc=>"Set to true/false"

      def upgrade_module
        puts "Upgrading this module: prep=#{options[:prep]}"

      end
    end
  end
end