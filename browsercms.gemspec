require File.dirname(__FILE__) + "/lib/cms/version.rb"

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = %q{browsercms}
  s.version = Cms::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["BrowserMedia"]
  s.date = %q{2011-03-15}
  s.summary = %q{BrowserCMS is a a general purpose, open source Web Content Management System (CMS), written using Ruby on Rails.}
  s.description = %q{Web Content Management in Rails.}
  s.email = %q{github@browsermedia.com}
  s.extra_rdoc_files = [
      "LICENSE.txt",
      "README.markdown"
  ]
  s.required_ruby_version = '>= 1.9.2'

  s.files         = `git ls-files`.split("\n")
  s.files         -= Dir['test/dummy/*']
  s.files -= Dir["lib/tasks/cucumber.rake"]
  s.files -= Dir["lib/tasks/cms.rake"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }


  s.add_dependency('rails', "~> 3.1")

  # Required only for bcms-upgrade
  s.add_dependency('term-ansicolor')
  s.add_dependency("jquery-rails")

end

