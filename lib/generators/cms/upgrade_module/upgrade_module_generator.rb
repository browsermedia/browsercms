module Cms
  module Generators


    class UpgradeModuleGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)

      def alter_gemfile
        append_to_file 'Gemfile', "gemspec"
      end

      # Needs to be more specific than the core BrowserCMS .gitigore
      # Assumed to be run 'after' browser_cms:cms
      def generate_gitignore
        remove_file '.gitignore'
        template 'gitignore.erb', '.gitignore'
      end

      def generate_module_files
        copy_file 'README', "public/bcms/#{name_of_module}/README"

        copy_file 'build_gem.rake', 'lib/tasks/build_gem.rake'
        template 'engine.erb', "lib/#{name_of_module}/engine.rb"
        template 'module_file.erb', "lib/#{name_of_module}.rb"
        template 'gemspec.erb', "#{name_of_module}.gemspec"

        template 'routes.erb', "lib/#{name_of_module}/routes.rb"
        route "routes_for_#{name_of_module}"
        template 'install.erb', "lib/generators/#{name_of_module}/install/install_generator.rb"
        template 'USAGE.erb', "lib/generators/#{name_of_module}/install/USAGE"
      end

      # BrowserCMS new generator should probably handle this
      def generate_default_template
        generate 'cms:template', 'default'
      end

      private

      # i.e. bcms_something
      def name_of_module
        name
      end

      # ie. BcmsSomething
      def gem_name
        name_of_module.camelize
      end

      # i.e. Something
      def short_project_name
       File.basename(name_of_module).match(/bcms_(.+)/)[1]
      end

      def cms_version
        Cms::VERSION
      end
    end
  end
end
