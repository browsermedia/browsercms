#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'


Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new('test:units') do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/unit/**/*_test.rb'
  t.verbose = false
end

Rake::TestTask.new('test:functionals') do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/functional/**/*_test.rb'
  t.verbose = false

end

Rake::TestTask.new('test:integration') do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/integration/**/*_test.rb'
  t.verbose = false
end

require 'cucumber'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format progress"
end

desc 'Runs all the tests'
task :test => 'app:test:prepare' do
  tests_to_run = ENV['TEST'] ? ["test:single"] : %w(test:units test:functionals test:integration features)
  errors = tests_to_run.collect do |task|
    begin
      Rake::Task[task].invoke
      nil
    rescue => e
      { :task => task, :exception => e }
    end
  end.compact

  if errors.any?
    puts errors.map { |e| "Errors running #{e[:task]}! #{e[:exception].inspect}" }.join("\n")
    abort
  end
end

task :default => :test

# Sample tasks to load sample data. This is unworking pseudocode at the moment.
#task 'db:load' do
  # `mysql --user=root --password name_of_database < test/dummy/db/backups/name_of_file.sql`
#end

#task 'db:dump' do
  # `mysqldump --user=name_of_user --password --database name_of_database > name_of_file.sql`
#end
