# Provides Rake tasks for BrowserCMS projects.

namespace :db do

  desc "[BrowserCMS] Creates and populates the initial database for a new project."
  task :install => ["db:create", "db:migrate", "db:seed"]

  desc "[BrowserCMS] Drop, create and migrate the database"
  task :reinstall => ["db:drop", "db:install"]

  namespace :seed do

    desc "[BrowserCMS] Loads just the seed data from db/browsercms.seeds.rb"
    task :browsercms => :environment do
      load File.join("db", "browsercms.seeds.rb")
    end
  end

end




