# Tasks for working with BrowserCMS that should not be packaged into the Gem
namespace :db do

  # This copy of the core CMS task is necessary because Engines push all existing Rails tasks under app:db:install
  desc 'Creates and populates the initial BrowserCMS database for a new project.'
  task :install => %w{ db:create db:migrate db:seed }


end

namespace :yard do
  desc "Clean up the YARD api docs"
  task :clean do
    FileUtils.rm_rf "doc/api"
  end
end