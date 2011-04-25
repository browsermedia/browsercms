require 'generators/browser_cms'
module BrowserCms
  module Generators

    # For creating a new BrowserCMS project (Used in conjunction with the blank, demo and module templates.
    class CmsGenerator < Base


      def enable_static_asset_serving
        application do
          code = "# BrowserCMS should serve static CMS assets (js, css, images) from the Gem\n"
          code = code + "config.serve_static_assets = true"
        end
      end

      def copy_migrations_and_custom_js_files

        files_to_copy = [
        # For FCKEditor customization. Not sure this is even necessary anymore
        'public/site/customconfig.js',

        # Migrations/seed data
        'db/migrate/20080815014337_browsercms_3_0_0.rb',
        'db/migrate/20091109175123_browsercms_3_0_5.rb',
        'db/migrate/20100705083859_browsercms_3_3_0.rb',
        'db/seeds.rb'
        ]

        files_to_copy.each do |file|
          copy_file file, file
        end

      end

    end
  end
end