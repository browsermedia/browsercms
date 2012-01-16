# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rdoc/task' # Need to run `gem install rdoc` to make this work.
require 'tasks/rails'

require 'bundler'
Bundler::GemHelper.install_tasks



