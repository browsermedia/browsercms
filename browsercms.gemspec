require File.dirname(__FILE__) + "/lib/cms/version.rb"

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "browsercms"
  s.version = Cms::VERSION

  s.authors = ["BrowserMedia"]
  s.homepage = "http://www.browsercms.org"
  s.summary = %q{Web Content Management in Rails}
  s.description = %q{BrowserCMS is a general purpose, open source Web Content Management System (CMS) that supports Ruby on Rails v4.0. It can be used as a standalone CMS, added to existing Rails projects or extended using Rails Engines.}
  s.email = %q{github@browsermedia.com}
  s.extra_rdoc_files = %w{
      LICENSE.txt
      COPYRIGHT.txt
      GPL.txt
      README.markdown
  }
  s.required_ruby_version = '>= 1.9.2'

  s.files = Dir["{app,bin,db,doc,lib,vendor}/**/*"]
  s.files += Dir[".yardopts"]
  s.files += Dir["config/routes.rb"]
  s.files -= Dir["lib/tasks/**/*"]
  s.files += Dir["lib/tasks/cms.rake"]

  # Test files are not used and throwing 'Gem::Package::TooLongFileName' errors during packaging, so we are going to skip for now.
  #s.test_files = Dir["test/**/*"]
  #s.files -= Dir["test/dummy/*"]

  s.executables = ["bcms", "browsercms"]

  s.add_dependency("rails", "~> 4.0.0")
  s.add_dependency("devise", "~> 3.0")
  s.add_dependency("sass-rails")
  s.add_dependency("bootstrap-sass")
  s.add_dependency("compass-rails", "~> 1.1.3")
  s.add_dependency("ancestry", "~> 2.0.0")
  s.add_dependency("ckeditor_rails", "~> 4.3.0")
  s.add_dependency("underscore-rails", "~> 1.4")
  s.add_dependency("jquery-rails", "~> 3.1")
  s.add_dependency("jquery-ui-rails", "~> 4.1")
  s.add_dependency("paperclip", "~> 3.5.1")
  s.add_dependency("panoramic")
  s.add_dependency("will_paginate", "~>3.0.0")
  s.add_dependency("actionpack-page_caching", "~>1.0")
  s.add_dependency("simple_form", ">= 3.0.0.rc", "< 3.1")

  # Required only for bcms-upgrade
  s.add_dependency "term-ansicolor"

end

