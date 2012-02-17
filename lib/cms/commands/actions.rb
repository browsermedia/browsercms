module Cms
  module Commands
    module Actions

      def self.included(klass)
        klass.source_root(File.expand_path(File.join(__FILE__, '../../../generators/cms/project/templates')))
      end

      def generate_installation_script
        template 'install.rb', "lib/generators/#{current_project}/install/install_generator.rb"
        template 'USAGE', "lib/generators/#{current_project}/install/USAGE"
        empty_directory "lib/generators/#{current_project}/install/templates"
      end

      def current_project
        @project_name || File.basename(Dir.pwd)
      end
    end
  end
end