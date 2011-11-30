require 'generators/browser_cms'
module BrowserCms
  module Generators

    # For creating a new BrowserCMS project (Used in conjunction with the blank, demo and module templates.
    class CmsGenerator < Base

      def copy_seed_files

        files_to_copy = [
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