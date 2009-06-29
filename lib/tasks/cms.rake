namespace :test do
  Rake::TestTask.new(:all => "db:test:prepare") do |t|
    t.libs << "test"
    t.pattern = 'test/**/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test:all'].comment = "Run all tests at once"
end

namespace :cms do
  
  desc "DEPRECATED"
  task :install do
    puts "This task has been deprecated, please use 'rake install' instead"
  end
  
  desc "Bumps the build number in lib/cms/init.rb"
  task :bump_build_number do
    init_file = Rails.root.join("lib/cms/init.rb")
    s = File.read(init_file)
    open(init_file, 'w') do |f| 
      f << s.sub(/def build_number; (\d+) end/) do |s|
        new_build_number = $1.to_i + 1
        puts "Build number bumped to #{new_build_number}"
        "def build_number; #{new_build_number} end"
      end
    end
  end
  
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
    
end
