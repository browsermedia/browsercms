# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "browsercms"
    gem.summary = %Q{A Content Management System for Rails}
    gem.email = "github@browsermedia.com"
    gem.homepage = "http://www.browsercms.org"
    gem.authors = ["BrowserMedia"]
    gem.files = Dir["rails/*.rb"]
    gem.files += Dir["browsercms.gemspec"]
    gem.files += Dir["app/**/*"]
    gem.files += Dir["db/migrate/[0-9]*_*.rb"]
    gem.files += Dir["db/demo/**/*"]
    gem.files += Dir["lib/**/*"]
    gem.files += Dir["rails_generators/**/*"]
    gem.files += Dir["public/stylesheets/cms/**/*"]
    gem.files += Dir["public/javascripts/jquery*"]
    gem.files += Dir["public/javascripts/cms/**/*"]
    gem.files += Dir["public/fckeditor/**/*"]
    gem.files += Dir["public/site/**/*"]
    gem.files += Dir["public/images/cms/**/*"]
    gem.files += Dir["public/themes/**/*"]

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
