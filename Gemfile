source 'http://rubygems.org'

# Load this project as a gem.
gemspec

gem "mysql"


gem 'yard', :groups=>[:development, :test]
gem 'bluecloth', :groups=>[:development, :test] # For YARD

gem 'rake', '0.8.7'

group :test do
  gem 'factory_girl_rails', '1.0.1'
  gem 'test-unit', '2.1.1'
  # :require=>false allows mocha to correctly modify the test:unit code to add mock() and stub()
  gem "mocha", '=0.9.8', :require=>false
  gem "sqlite3-ruby", :require => "sqlite3"

  gem 'capybara', '0.4.1.1'
  gem 'database_cleaner'
  gem 'cucumber-rails'
  gem 'cucumber', '0.10.0'
  gem 'rspec-rails', '2.4.1'
  gem 'spork'
  gem 'launchy', '0.3.7'

end
