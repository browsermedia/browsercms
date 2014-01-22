# Tasks for working with BrowserCMS that should not be packaged into the Gem
namespace :db do

  # This copy of the core CMS task is necessary because Engines push all existing Rails tasks under app:db:install
  desc 'Creates and populates the initial BrowserCMS database for a new project.'
  task :install => %w{ db:create db:migrate db:seed }

  desc 'Truncates database tables (without dropping like db:reset)'
  task :clean => :environment do
    require 'database_cleaner'
    DatabaseCleaner.clean_with(:truncation)
  end

  desc '[TEST] Creates sample products'
  task :many_products => :environment do
    (1..100).each do |i|
      Dummy::Product.create(name: "Product #{i}")
    end
  end

  namespace :yard do
    desc "Clean up the YARD api docs"
    task :clean do
      FileUtils.rm_rf "doc/api"
    end
  end
end

# These are tasks for the core browsercms project, and shouldn't be bundled into the distributable gem
namespace :project do

  # Could be improved somewhat to get rid of unneeded warnings.
  #desc "run tests against sqlite database"
  #task :sqlite3 do
  #  cp(File.join('config', 'database.sqlite3.yml'), File.join('config', 'database.yml'), :verbose => true)
  #  Rake::Task['db:drop'].invoke
  #  Rake::Task['db:create'].invoke
  #  system "rake db:migrate test"
  #end
  #
  ## Could be improved somewhat to get rid of unneeded warnings.
  #desc "run tests against mysql database"
  #task :mysql do
  #  cp(File.join('config', 'database.mysql.yml'), File.join('config', 'database.yml'), :verbose => true)
  #  Rake::Task['db:drop'].invoke
  #  Rake::Task['db:create'].invoke
  #  system "rake db:migrate test"
  #end

  task :ensure_db_exists do
    unless File.exists?("test/dummy/config/database.yml")
      fail("Need to create a database.yml file before running tests. Run:\n $ rake project:setup[database] to create a sample database.yml for the project.")
    end
  end


  desc 'Copy database.yml files for running tests'
  task :setup, :database do |t, args|
    drivers = %w(jdbcmysql mysql postgres sqlite3)
    unless drivers.include?(args[:database])
      fail("'#{args[:database]}' is not an available database. Choose from one of the following #{drivers.inspect}. i.e\n\t$ rake project:setup[mysql]")
    end

    source = File.join('test/dummy/config', "database.#{args[:database]}.yml")
    destination = File.join('test/dummy/config', "database.yml")
    cp(source, destination, :verbose => true)


  end

  namespace :setup do
    task :mysql do
      Rake::Task['project:setup'].invoke('mysql')
    end
  end
end