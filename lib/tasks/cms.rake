namespace :test do
  Rake::TestTask.new(:all => "db:test:prepare") do |t|
    t.libs << "test"
    t.pattern = 'test/**/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test:all'].comment = "Run all tests at once"
end

# When Jeweler builds the gem, make sure the guides are also rebuilt.
task :build => ['cms:guides']

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
end
