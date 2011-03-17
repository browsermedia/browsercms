namespace :test do

  desc 'Runs all Tests (Test::Unit) and Features (cucumber)'
  task :all => ["test", "cucumber"]

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

namespace :cms do
  
  desc "Generate guides for the CMS"
  task :guides do
    require 'rubygems'

    gem "actionpack", '>= 2.3'
    require "action_controller"
    require "action_view"

    gem 'RedCloth', '>= 4.1.1'
    require 'redcloth'

    $: << File.join(File.dirname(__FILE__), '../../doc/guides')

    module CmsGuides
      autoload :Generator, "cms_guides/generator"
      autoload :Indexer, "cms_guides/indexer"
      autoload :Helpers, "cms_guides/helpers"
      autoload :TextileExtensions, "cms_guides/textile_extensions"
      autoload :Levenshtein, "cms_guides/levenshtein"
    end

    RedCloth.send(:include, CmsGuides::TextileExtensions)

    CmsGuides::Generator.new.generate

  end    

  desc "Rebuild the browsercms gem locally and install it, Useful for testing releases."
  task :gem => ["browsercms.gemspec", :build, :install]

  task :install do
    puts "installing..."
    if RUBY_PLATFORM =~ /mswin32/
      system("cmd /c gem install pkg/browsercms-3.1.0")
    else
      sh("sudo gem install pkg/browsercms-3.1.0")
    end
  end
end

