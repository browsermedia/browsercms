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

Rake::TestTask.new('test:units' => 'app:test:prepare') do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/unit/**/*_test.rb'
  t.verbose = false
end

Rake::TestTask.new('test:functionals' => 'app:test:prepare') do |t|
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

Cucumber::Rake::Task.new('features:fast') do |t|
  t.cucumber_opts = "features --format progress --tags ~@cli"
end

Cucumber::Rake::Task.new('features:cli') do |t|
  t.cucumber_opts = "features --format progress --tags @cli"
end


desc "Run everything but the command line (slow) tests"
task 'test:fast' => %w{test:units test:functionals test:integration features:fast}

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
