module Cms

  # A generic generator for installing BrowserCMS modules into a project. This will do the following:
  #
  # 1. Add the Gem to your Gemfile
  # 2. Call the name_of_module:install generator for that gem.
  class InstallGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def add_and_install_module
      gem name
      generate("#{name}:install")
    end

  end
end
