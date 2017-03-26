source 'http://rubygems.org'

ruby '2.3.0'

# Load this project as a gem.
gemspec
gem "mysql2"

gem 'yard', :groups=>[:development, :test]
gem 'bluecloth', :groups=>[:development, :test] # For YARD
# gem 'query_reviewer' # Enable for performance tuning

gem "thin" # To avoid annoying Ruby 1.9.3/Rails/Webrick warnings - See http://stackoverflow.com/questions/7082364/what-does-warn-could-not-determine-content-length-of-response-body-mean-and-h

gem 'sass-rails', '~>5.0.0'
gem 'sprockets-rails', '~>2.3.1'

# Uncomment to confirm that older versions work (for compaitiblity with Spree 2.2.4/bcms_spree)
# gem 'paperclip', '~> 3.4.1'
# For testing behavior in production
group :production do
  gem 'uglifier'
end

group :development do
  gem 'rake'
  # gem 'debugger'
  gem 'quiet_assets'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry'
end
group :test, :development do
  gem 'minitest', '~>5.3.3'
  gem "test-unit", "~> 3.0"
  gem 'minitest-rails', '~>2.0.0'
  gem 'minitest-reporters', '~>1.0.0'
end

group :test do
  gem 'poltergeist'
  gem 'm', '~> 1.2'
  gem 'single_test'
  gem 'factory_girl_rails', '3.3.0'
  gem "mocha", :require=>false
  gem "sqlite3-ruby", :require => "sqlite3"

  # Cucumber and dependencies
  gem 'capybara'
  gem 'database_cleaner'
  gem 'cucumber-rails', '~> 1.4.1', :require=> false
  gem 'cucumber'
  gem 'launchy'
  gem 'ruby-prof'
  gem 'aruba'
end
