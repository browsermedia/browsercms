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
        inject_into_file "lib/#{current_project}/engine.rb", :after => "isolate_namespace #{module_class}\n" do
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

      # Runs `bundle install` inside the correct project directory (unless --skip_bundle was passed to the command)
      def run_bundle_install
        inside current_project do
          run "bundle install" unless options[:skip_bundle]
        end
      end

      def comment_out_rails_in_gemfile
        gsub_file "Gemfile", /gem ["|']rails["|'],/, "# Use BrowserCMS dependency on Rails instead\n# gem 'rails',"
      end

      def update_browsercms_gem_version
        gsub_file "Gemfile", /gem ["|']browsercms.*$/, "gem \"browsercms\", \"#{Cms::VERSION}\""
      end

      def install_migrations
        rake 'cms:install:migrations'
      end

      def install_cms_seed_data
        # Copy from Gem
        copy_file File.expand_path(File.join(__FILE__, "../../../../db/browsercms.seeds.rb")), "db/browsercms.seeds.rb"
        append_to_file('db/seeds.rb', "\nrequire File.expand_path('../browsercms.seeds.rb', __FILE__)\n")
      end

      # Adds a route as the last file of the project.
      # Assumes we are inside the rails app.
      def add_route_to_end(route)
        inject_into_file 'config/routes.rb', "\n  #{route}\n", {:before => /^end$/}
      end

      # Find the first migration within the current project given a partial name:
      #   i.e. create_turtles
      # Might find 20120314204817_create_turtles.rb
      #
      # @param [String] name Partial file name. Don't include the .rb at the end
      # @return [String] Full path to the file, so you can do file manipulation on it.
      def migration_with_name(name)
        file_pattern = "db/migrate/*#{name}.rb"
        files = Dir.glob(file_pattern)
        fail "Couldn't find a migration file matching this pattern (#{file_pattern})'" if files.empty?
        File.absolute_path(files.first)
      end

      # Returns a list of all models in the current project.
      # @return [Array<String>] List of file names matching the models
      def find_custom_blocks
        file_pattern = "app/models/*.rb"
        files = Dir.glob(file_pattern)
        files.map do |s|
          File.basename(s, ".rb")
        end
      end
    end
  end
end