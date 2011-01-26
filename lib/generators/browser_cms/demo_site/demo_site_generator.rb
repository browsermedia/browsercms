require 'generators/browser_cms'
require 'rails/generators/migration'
module BrowserCms
  module Generators
    class DemoSiteGenerator < Base
      include Rails::Generators::Migration
      
      def create_demo_site
        # Copy all public files
        Dir["#{Cms.root}/public/themes/blue_steel/**/*"].each do |f|
          if File.file?(f)
            file_name = f.sub("#{Cms.root}/", '')
            directory File.dirname(file_name)
            copy_file Cms.scrub_path(f), file_name
          end
        end

        %W( lib/tasks/demo_site.rake ).each{|f|
          copy_file Cms.scrub_path("#{Cms.root}/#{f}"), f
        }

        template templates_dir('migration.rb'), 'db/demo_site_seeds.rb', :assigns => {
          :data => data,
          :page_templates => page_templates,
          :page_partials => page_partials
        } 
               
      end

      private
      def templates_dir(file=nil)
        f = File.expand_path(File.join(File.dirname(__FILE__), "templates", file))
        Cms.scrub_path(f)
      end      
      def data
        open(File.join(Cms.root, "db", "demo", "data.rb")){|f| f.read}
      end
      
      # Returns an array of strings that are ruby code.
      # Each string is a hash that should be passed to the create_page_template method
      # in the migration
      def page_templates
        Dir["#{Cms.root}/db/demo/page_templates/*.erb"].map do |f|
          name, format, handler = File.basename(f).split('.')
          %Q{create_page_template(:#{name}, 
            :name => "#{name}", :format => "#{format}", :handler => "#{handler}", 
            :body => <<-HTML
    #{open(f){|f| f.read}}
          HTML
          )}
        end
      end
      
      def page_partials
        Dir["#{Cms.root}/db/demo/page_partials/*.erb"].map do |f|
          name, format, handler = File.basename(f).split('.')
          %Q{create_page_partial(:#{name}, 
            :name => "#{name}", :format => "#{format}", :handler => "#{handler}", 
            :body => <<-HTML
    #{open(f){|f| f.read}}
          HTML
          )}
        end
      end      

      # FIXME: Should be proxied to ActiveRecord::Generators::Base
      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        if ActiveRecord::Base.timestamped_migrations
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end
    end
  end
end
# class BrowserCmsDemoSiteGenerator < Rails::Generator::Base
#   
#   def source_root
#     "/"
#   end
#   
#   def templates_dir(file=nil)
#     f = File.expand_path(File.join(File.dirname(__FILE__), "templates", file))
#     Cms.scrub_path(f)
#   end
#   
#   def manifest
#     record do |m|
#       # Copy all public files
#       Dir["#{Cms.root}/public/themes/blue_steel/**/*"].each do |f|
#         if File.file?(f)
#           file_name = f.sub("#{Cms.root}/", '')
#           m.directory File.dirname(file_name)
#           m.file Cms.scrub_path(f), file_name
#         end
#       end
#       
#       m.migration_template templates_dir('migration.rb'), 'db/migrate', :assigns => {
#         :data => data,
#         :page_templates => page_templates,
#         :page_partials => page_partials
#       }, :migration_file_name => "load_demo_site_data"
#       
#     end
#   end
#   
#   def data
#     open(File.join(Cms.root, "db", "demo", "data.rb")){|f| f.read}
#   end
#   
#   # Returns an array of strings that are ruby code.
#   # Each string is a hash that should be passed to the create_page_template method
#   # in the migration
#   def page_templates
#     Dir["#{Cms.root}/db/demo/page_templates/*.erb"].map do |f|
#       name, format, handler = File.basename(f).split('.')
#       %Q{create_page_template(:#{name}, 
#         :name => "#{name}", :format => "#{format}", :handler => "#{handler}", 
#         :body => <<-HTML
# #{open(f){|f| f.read}}
#       HTML
#       )}
#     end
#   end
#   
#   def page_partials
#     Dir["#{Cms.root}/db/demo/page_partials/*.erb"].map do |f|
#       name, format, handler = File.basename(f).split('.')
#       %Q{create_page_partial(:#{name}, 
#         :name => "#{name}", :format => "#{format}", :handler => "#{handler}", 
#         :body => <<-HTML
# #{open(f){|f| f.read}}
#       HTML
#       )}
#     end
#   end
#   
# end