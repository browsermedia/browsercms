desc "Reset the DB, run the migrations, load the fixtures, run the specs"
task :reset => ["db:migrate:reset", "db:load_initial_data", "spec"]

namespace :db do
  
  desc "Loads initial data"
  task :load_initial_data => :environment do
    InitialData.load_data
  end
  
end

namespace :cms do
  desc "Imports the data from a BrowserCMS 2.5 Schema"
  task :import => [:environment, 'db:migrate:reset'] do
    Cms::Import.import(:connection => {
      :username => "root",
      :password => "",
      :database => "microbicide"
    })
  end
  
end
