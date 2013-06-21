source 'http://rubygems.org'

# Load this project as a gem.
gemspec
gem "panoramic"
gem "mysql2"

gem 'yard', :groups=>[:development, :test]
gem 'bluecloth', :groups=>[:development, :test] # For YARD
# gem 'query_reviewer' # Enable for performance tuning

gem "thin" # To avoid annoying Ruby 1.9.3/Rails/Webrick warnings - See http://stackoverflow.com/questions/7082364/what-does-warn-could-not-determine-content-length-of-response-body-mean-and-h

# For testing behavior in production
group :production do
  gem 'uglifier'
end

group :assets do
  gem 'sass-rails'
  gem 'bootstrap-sass'
end


group :development do
  gem 'rake', '~> 0.9.5'
end
group :test, :development do
  gem 'minitest'
  gem 'minitest-rails'
end

group :test do
  gem 'poltergeist'
  gem 'm', '~> 1.2'

  gem 'factory_girl_rails', '3.3.0'
  gem "mocha", :require=>false
  gem "sqlite3-ruby", :require => "sqlite3"

  # Cucumber and dependencies
  gem 'capybara'
  gem 'database_cleaner'
  gem 'cucumber-rails', :require=> false
  gem 'cucumber'
  gem 'launchy'
  gem 'ruby-prof'
  gem 'aruba'
end
