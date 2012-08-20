# Tasks for working with BrowserCMS that should not be packaged into the Gem
namespace :db do

  # This copy of the core CMS task is necessary because Engines push all existing Rails tasks under app:db:install
  desc 'Creates and populates the initial BrowserCMS database for a new project.'
  task :install => %w{ db:create db:migrate db:seed }


end

namespace :yard do
  desc "Clean up the YARD api docs"
  task :clean do
    FileUtils.rm_rf "doc/api"
  end
end


# These are tasks for the core browsercms project, and shouldn't be bundled into the distributable gem
namespace :test do

    # Could be improved somewhat to get rid of unneeded warnings.
  desc "run tests against sqlite database"
  task :sqlite3 do
    cp(File.join('config', 'database.sqlite3.yml'), File.join('config', 'database.yml'), :verbose => true)
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    system "rake db:migrate test"
  end

    # Could be improved somewhat to get rid of unneeded warnings.
  desc "run tests against mysql database"
  task :mysql do
    cp(File.join('config', 'database.mysql.yml'), File.join('config', 'database.yml'), :verbose => true)
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    system "rake db:migrate test"
  end

  desc 'Copy database.yml files for running tests'
  task :setup do
    drivers = %w(jdbcmysql mysql postgres sqlite3).each do |driver|
      source      = File.join('config', "database.#{driver}.yml.example")
      destination = File.join('config', "database.#{driver}.yml")
      cp(source, destination, :verbose => true)
    end

    source      = File.join('test/dummy/config', "database.yml.example")
    destination = File.join('test/dummy/config', "database.yml")
    cp(source, destination, :verbose => true)
  end
end