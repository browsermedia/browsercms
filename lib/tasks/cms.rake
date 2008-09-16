namespace :cms do
  usage = "USAGE: rake cms:import CMS_PATH=/Users/pbarry/Projects/cmsamerica CMS_DB_NAME=cmsamerica"
  desc "Imports the data from a BrowserCMS 2.5 Schema.  You must specify the path to the CMS code and the #{usage}"
  task :import => [:environment, 'db:migrate:reset'] do
    fail "You must specify a value for CMS_PATH\n#{usage}" unless ENV['CMS_PATH']
    fail "You must specify a value for CMS_DB_NAME\n#{usage}" unless ENV['CMS_DB_NAME']
    Cms::Import.import(
      :cms_path => ENV['CMS_PATH'],
      :connection => {
        :adapter  => ENV['CMS_DB_TYPE'] || "mysql",
        :host     => ENV['CMS_DB_HOST'] || "localhost",       
        :username => ENV['CMS_DB_USER'] || "root",
        :password => ENV['CMS_DB_PASS'] || "",
        :database => ENV['CMS_DB_NAME']
      }
    )
  end
  
  desc "Copies the public assets from the CMS gem into your project"
  task :install => [:environment] do
    CmsRoot = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
    file = File.expand_path(File.join(Rails.root, "public/index.html"))
    if File.exists?(file)
      puts "Removing #{file}..."
      FileUtils.rm(file)
    end
    %w[public/javascripts/cms public/stylesheets/cms public/images/cms].each do |f|
      from = File.expand_path(File.join(CmsRoot, f))
      to = File.expand_path(File.join(Rails.root, f))
      if File.exists?(to)
        puts "Removing #{to}..."
        FileUtils.rm_r to
      end
      puts "Copying #{from} to #{to}..."
      FileUtils.cp_r from, to
    end
  end
  
end
