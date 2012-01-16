require File.dirname(__FILE__) + "/lib/cms/version.rb"

Gem::Specification.new do |s|
  s.name = %q{browsercms}
  s.version = Cms::VERSION

  s.authors = ["BrowserMedia"]
  s.description = %q{General purpose Web Content Management in Rails.}
  s.summary = %Q{BrowserCMS is a general purpose, open source Web Content Management System (CMS) written in Ruby on Rails. Designed for web developers who want to create great looking websites while using standard Rails tools for customizing it. }

  s.email = %q{github@browsermedia.com}
  s.executables = ["browsercms", "bcms"]
  s.extra_rdoc_files = [
      "LICENSE.txt",
      "README.markdown"
  ]
  s.files = Dir["rails/*.rb"]
  s.files += Dir["browsercms.gemspec"]
  s.files += Dir["doc/app/**/*"]
  s.files += Dir["doc/guides/html/**/*"]
  s.files += Dir["app/**/*"]
  s.files += Dir["db/migrate/[0-9]*_*.rb"]
  s.files += Dir["db/demo/**/*"]
  s.files += Dir["lib/**/*"]
  s.files += Dir["rails_generators/**/*"]
  s.files += Dir["public/stylesheets/cms/**/*"]
  s.files += Dir["public/javascripts/jquery*"]
  s.files += Dir["public/javascripts/cms/**/*"]
  s.files += Dir["public/bcms/**/*"]
  s.files += Dir["public/site/**/*"]
  s.files += Dir["public/images/cms/**/*"]
  s.files += Dir["public/themes/**/*"]
  s.files += Dir["templates/*.rb"]

  s.homepage = %q{http://www.browsercms.org}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{browsercms}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{BrowserCMS is a general purpose, open source Web Content Management System (CMS) written in Ruby on Rails. Designed for web developers who want to create great looking websites while using standard Rails tools for customizing it.}
  s.test_files = Dir["test/**/*"]


end

