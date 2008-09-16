#These are tasks used for the development of CMS as a standalone rails app, not to be included into a CMS project

desc "Reset the DB, run the migrations, load the fixtures, run the specs"
task :reset => ["db:migrate:reset", "db:load_initial_data", "spec"]

namespace :db do
  
  desc "Loads initial data"
  task :load_initial_data => :environment do
    InitialData.load_data
  end
  
end