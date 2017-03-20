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
require 'single_test/tasks'

Rake::TestTask.new('units') do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/unit/**/*_test.rb'
  t.verbose = false
end

Rake::TestTask.new('spec') do |t|
  t.libs << 'lib'
  t.libs << 'spec'
  t.pattern = "spec/**/*_spec.rb"
end

Rake::TestTask.new('test:functionals' => ['project:ensure_db_exists', 'app:test:prepare']) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/functional/**/*_test.rb'
  t.verbose = false

end

require 'cucumber'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features, "Run all (fast) scenarios without known bugs or missing features") do |t|
  t.cucumber_opts = "launch_on_failure=false features --format progress --tags ~@cli -t ~@missing-feature -t ~@known-bug"
end

Cucumber::Rake::Task.new('features:all', 'Runs all scenarios (including slow/missing/etc') do |t|
  t.cucumber_opts = "launch_on_failure=false features --format progress"
end

Cucumber::Rake::Task.new('features:cli' => ['project:ensure_db_exists', 'app:test:prepare']) do |t|
  t.cucumber_opts = "features --format progress --tags @cli"
end

Cucumber::Rake::Task.new('features:wip', 'Run all (fast) scenarios without known bugs/features.') do |t|
  t.cucumber_opts = "features --format progress --tags ~@cli -t ~@known-bug -t ~@missing-feature"
end

Cucumber::Rake::Task.new('features:wip:all', 'Run all scenarios (including slow) without known bugs/missing features.') do |t|
  t.cucumber_opts = "features --format progress -t ~@known-bug -t ~@missing-feature"
end

Cucumber::Rake::Task.new('features:known-bugs', 'Run all scenarios with known bugs.') do |t|
  t.cucumber_opts = "features --format progress -t @known-bug"
end

#Rake::Task['features:wip'].enhance ['project:ensure_db_exists', 'app:test:prepare']

desc "Run everything but the command line (slow) tests"
task 'test:fast' => %w{app:test:prepare test:units test:functionals features}

desc "Runs all unit level tests"
task 'test:units' => ['app:test:prepare'] do
  run_tests ["units", "spec"]
end

desc 'Runs all the tests, specs and scenarios.'
task :test => ['project:ensure_db_exists', 'app:test:prepare'] do
  tests_to_run =  %w(test:units spec test:functionals features)
  run_tests(tests_to_run)
end

def run_tests(tests_to_run)
  errors = tests_to_run.collect do |task|
    begin
      Rake::Task[task].invoke
      nil
    rescue => e
      {:task => task, :exception => e}
    end
  end.compact

  if errors.any?
    puts errors.map { |e| "Errors running #{e[:task]}! #{e[:exception].inspect}" }.join("\n")
    abort
  end
end

# Build and run against MySQL.
task 'ci:test' => ['project:setup:mysql', 'db:drop', 'db:create:all', 'db:install', 'test']
task :default => 'ci:test'

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.options = ['--output-dir', 'doc/api/']
end

# Load all tasks files
#Dir.glob('lib/tasks/*.rake').each { |r| import r }

# Load just this one task file instead (the previous rake files can probably be simplified)
import 'lib/tasks/core_tasks.rake'

begin
  require 'cucumber/rake/task'
  namespace :cucumber do
    Cucumber::Rake::Task.new({:launch => 'db:test:prepare'}, 'Run features opening failures in the browser') do |t|
      t.fork = true # You may get faster startup if you set this to false
      t.profile = 'default'
      t.cucumber_opts = ["-f", "Debug::Formatter"]
    end
  end
end
