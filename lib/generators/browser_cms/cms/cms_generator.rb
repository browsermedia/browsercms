require 'generators/browser_cms'
module BrowserCms
  module Generators

    # For creating a new BrowserCMS project (Used in conjunction with the blank, demo and module templates.
    class CmsGenerator < Base

      def copy_migrations_and_custom_js_files

        files_to_copy = [
        # Migrations/seed data
        'db/migrate/20080815014337_browsercms_3_0_0.rb',
        'db/migrate/20091109175123_browsercms_3_0_5.rb',
        'db/migrate/20100705083859_browsercms_3_3_0.rb',
        'db/browsercms.seeds.rb'
        ]

        files_to_copy.each do |file|
          copy_file file, file
        end

        append_to_file('db/seeds.rb') do
          "require File.expand_path('../browsercms.seeds.rb', __FILE__)"
        end
      end

    end
  end
end