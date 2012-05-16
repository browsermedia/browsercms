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
end




