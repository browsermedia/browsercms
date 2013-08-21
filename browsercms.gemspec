require File.dirname(__FILE__) + "/lib/cms/version.rb"

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = "browsercms"
  s.version = Cms::VERSION

  s.authors = ["BrowserMedia"]
  s.homepage = "http://www.browsercms.org"
  s.summary = %q{Web Content Management in Rails}
  s.description = %q{BrowserCMS is a general purpose, open source Web Content Management System (CMS) that supports Ruby on Rails v3.2. It can be used as a standalone CMS, added to existing Rails projects or extended using Rails Engines.}
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

  s.executables = ["bcms", "bcms-upgrade","browsercms"]

  s.add_dependency("rails", "< 3.3.0", ">= 3.2.5")
  s.add_dependency("sass-rails")
  s.add_dependency("bootstrap-sass")
  s.add_dependency("ancestry", "~> 1.2.4")
  s.add_dependency("ckeditor_rails", "~> 4.0.1.1")
  s.add_dependency("underscore-rails", "~> 1.4")
  s.add_dependency("jquery-rails", "~> 2.0")
  s.add_dependency("paperclip", "~> 3.0.3")
  s.add_dependency("panoramic")

  # Required only for bcms-upgrade
  s.add_dependency "term-ansicolor"

end

