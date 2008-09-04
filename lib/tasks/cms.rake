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
    Cms::Import.import(
      :cms_path => ENV['CMS_PATH'],
      :connection => {
        :username => ENV['CMS_DB_USER'] || "root",
        :password => ENV['CMS_DB_PASS'] || "",
        :database => ENV['CMS_DB_NAME']
      }
    )
  end
  
end
