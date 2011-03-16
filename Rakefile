# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

Browsercms::Application.load_tasks

require 'bundler'
Bundler::GemHelper.install_tasks

#require File.dirname(__FILE__) + "/lib/cms/version.rb"
#begin
#  require 'jeweler'
#  Jeweler::Tasks.new do |gem|
#    gem.name = "browsercms"
#    gem.version = Cms::VERSION
#    gem.summary = %Q{BrowserCMS is a general purpose, open source Web Content Management System (CMS), written in Ruby on Rails.}
#    gem.description = %Q{Web Content Management in Rails.}
#    gem.email = "github@browsermedia.com"
#    gem.homepage = "http://www.browsercms.org"
#    gem.authors = ["BrowserMedia"]
#    gem.rubyforge_project = 'browsercms'
#    gem.executables = ['browsercms', 'bcms', 'bcms-upgrade']
#    gem.files = Dir["rails/*.rb"]
#    gem.files += Dir["browsercms.gemspec"]
#    gem.files += Dir["doc/app/**/*"]
#    gem.files += Dir["doc/guides/html/**/*"]
#    gem.files += Dir["app/**/*"]
#    gem.files += Dir["db/migrate/[0-9]*_*.rb"]
#    gem.files += Dir["db/demo/**/*"]
#    gem.files += Dir["db/seeds.rb"]
#    gem.files += Dir["lib/**/*"]
#    gem.files += Dir["public/stylesheets/cms/**/*"]
#    gem.files += Dir["public/javascripts/jquery*"]
#    gem.files += Dir["public/javascripts/cms/**/*"]
#    gem.files += Dir["public/bcms/**/*"]
#    gem.files += Dir["public/site/**/*"]
#    gem.files += Dir["public/images/cms/**/*"]
#    gem.files += Dir["public/themes/**/*"]
#    gem.files += Dir["templates/*.rb"]
#    gem.files -= Dir['test/dummy/*']
#
#    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
#  end
#rescue LoadError
##  puts "Jeweler not available. Install it with: gem install jeweler"
#end
#
## These are new tasks
#begin
#  require 'rake/contrib/sshpublisher'
#  namespace :rubyforge do
#
#    desc "Release gem to RubyForge"
#    task :release => ["rubyforge:release:gem"]
#
#
#  end
#rescue LoadError
#  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
#end

