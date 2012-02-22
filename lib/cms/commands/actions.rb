module Cms
  module Commands
    module Actions

      def self.included(klass)
        klass.source_root(File.expand_path(File.join(__FILE__, '../../../generators/cms/project/templates')))
      end

      def generate_installation_script
        template 'install_generator.erb', "lib/generators/#{current_project}/install/install_generator.rb"
        template 'USAGE', "lib/generators/#{current_project}/install/USAGE"
        empty_directory "lib/generators/#{current_project}/install/templates"
      end

      def include_cms_module
        inject_into_file "lib/#{current_project}/engine.rb", :after=>"isolate_namespace #{module_class}\n" do
          "\t\tinclude Cms::Module\n"
        end
      end

      def current_project
        @project_name || File.basename(Dir.pwd)
      end

      # i.e. BcmsWhatever
      def module_class
        current_project.classify
      end

      # Adds a route as the last file of the project.
      # Assumes we are inside the rails app.
      def add_route_to_end(route)
        inject_into_file 'config/routes.rb', "\n  #{route}\n", {:before => /^end$/}
      end
    end
  end
end