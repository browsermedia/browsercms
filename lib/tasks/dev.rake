#These are tasks used for the development of CMS as a standalone rails app, not to be included into a CMS project

desc "Reset the DB, run the migrations, load the fixtures, run the specs"
task :reset => ["db:reload_demo_data", "test:all"]

namespace :db do
  # This task needs to somehow be packaged as part of the CMS gem, so that users can use the demo.rb template to install the data.
  
  desc "Installs sample data for a demo site, including several templates and sample pages."
  task :load_demo_data => :environment do
    t0 = Time.now
    puts "== Demo Data: creating ====================================================="    
    InitialData.load_demo
    puts "== Demo Data: created (%0.4fs) ============================================\n" % (Time.now - t0)    
  end
  
  
  desc "Wipes database, and reinstalls the demo data."
  task :reload_demo_data => ["db:migrate:reset", "db:load_demo_data"]
end