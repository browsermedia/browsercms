source 'http://rubygems.org'

# Load this project as a gem.
gemspec

gem "mysql2"

gem 'yard', :groups=>[:development, :test]
gem 'bluecloth', :groups=>[:development, :test] # For YARD
# gem 'query_reviewer' # Enable for performance tuning

gem "thin" # To avoid annoying Ruby 1.9.3/Rails/Webrick warnings - See http://stackoverflow.com/questions/7082364/what-does-warn-could-not-determine-content-length-of-response-body-mean-and-h

# For testing behavior in production
group :production do
  gem 'uglifier'
end

group :test do
  gem 'factory_girl_rails'
  gem 'test-unit', '2.1.1'
  # :require=>false allows mocha to correctly modify the test:unit code to add mock() and stub()
  gem "mocha", '=0.9.8', :require=>false
  gem "sqlite3-ruby", :require => "sqlite3"

  # Cucumber and dependencies
  gem 'capybara'
  gem 'database_cleaner'
  gem 'cucumber-rails'
  gem 'cucumber'
  gem 'launchy'
  gem 'ruby-prof'
  gem 'aruba'
end
