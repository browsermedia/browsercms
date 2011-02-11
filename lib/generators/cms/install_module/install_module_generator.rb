require 'generators/browser_cms/cms/cms_generator'

module Cms
  class InstallModuleGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    include BrowserCms::Generators::GemFileExtractor
    # To install a module, i must

    # require the gem (so that it adds its own migrations to loadpath)

    def add_gem
      gem name

      generator('browser_cms:cms')
    end
#    def require_gem
#      puts "Requiring #{name}"
#
#      # This doesn't work, because we don't have it in our project yet.
#      require name
#    end

    def copy_files_from_gem
      puts "Copy files"
    end
    # Call the copy files generator from core CMS generator.
  end
end
