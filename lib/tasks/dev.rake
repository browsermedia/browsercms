#These are tasks used for the development of CMS as a standalone rails app, not to be included into a CMS project

desc "Reset the DB, run the migrations, load the fixtures, run the specs"
task :reset => ["db:migrate:reset", "db:load_initial_data", "test:all"]

namespace :db do
  
  desc "Loads initial data"
  task :load_initial_data => :environment do
    t0 = Time.now
    puts "== Initial Data: creating ====================================================="    
    InitialData.load_data
    puts "== Initial Data: created (%0.4fs) ============================================\n" % (Time.now - t0)    
  end
  
end