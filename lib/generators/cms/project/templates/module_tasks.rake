# Provides tasks to make developing BrowserCMS modules easier.
# Should not be packaged with the gem.
namespace :db do

  # This copy of the core CMS taks is necessary because Engines push all existing Rails tasks under app:db:install
  desc 'Creates and populates the initial BrowserCMS database for a new project.'
  task :install => %w{ db:create db:migrate db:seed }


end