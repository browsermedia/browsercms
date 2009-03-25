run "rm public/index.html"
gem "browser_cms"
route "map.routes_for_browser_cms"
generate(:browser_cms)
rake("db:create")
rake("db:migrate")

rakefile("demo_data.rake") do
  <<-TASK
  namespace :db do
  
    task :load_demo_data => :environment do
      t0 = Time.now
      puts "== Demo Data: creating ================================================"    
      InitialData.load_demo
      puts "== Demo Data: created (%0.4fs) ========================================\n" % (Time.now - t0)    
    end
  end
  TASK
end
rake("db:load_demo_data")