#These are tasks used for the development of CMS as a standalone rails app, not to be included into a CMS project

desc "Reset the DB, run the migrations, load the fixtures, run the specs"
task :reset => ["db:migrate:reset", "test:all"]

namespace :db do
  
  desc "Loads data for demo site."
  task :load_demo_data => :environment do
    t0 = Time.now
    puts "== Demo Data: creating ====================================================="    
    InitialData.load_demo
    puts "== Demo Data: created (%0.4fs) ============================================\n" % (Time.now - t0)    
  end
  
end