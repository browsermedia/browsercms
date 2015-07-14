source 'http://rubygems.org'

# Load this project as a gem.
gemspec :name => "browsercms"
gem "mysql2"

# for fixing assets in tests
gem 'sass-rails', '5.0.1'
gem 'compass', '1.0.3'
gem 'compass-rails', '2.0.4'
gem 'bootstrap-sass', '~> 3.2'

gem 'yard', :groups=>[:development, :test]
gem 'bluecloth', :groups=>[:development, :test] # For YARD
# gem 'query_reviewer' # Enable for performance tuning

gem "thin" # To avoid annoying Ruby 1.9.3/Rails/Webrick warnings - See http://stackoverflow.com/questions/7082364/what-does-warn-could-not-determine-content-length-of-response-body-mean-and-h

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

  # ignoring artirix_gem_release in public github repo
  # gem 'artirix_gem_release', :git => "git@gitlab.artirix.com:artirix/artirix_gem_release.git"
end
group :test, :development do
  gem 'minitest'
  gem 'minitest-rails'
  gem 'minitest-reporters'
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'pry-doc'
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
  gem 'cucumber-rails', :require=> false
  gem 'cucumber'
  gem 'launchy'
  gem 'ruby-prof'
  gem 'aruba'
end

gem 'codeclimate-test-reporter', group: :test, require: nil
