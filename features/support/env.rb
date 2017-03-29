# Added for BrowserCMS (to test using test/dummy app)
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../../test/dummy/config/environment.rb", __FILE__)
ENV["RAILS_ROOT"] ||= File.dirname(__FILE__) + "../../../test/dummy"

require 'factory_girl'
require 'factory_girl/step_definitions'
require File.join(File.dirname(__FILE__), '../../test/factories/factories')
require File.join(File.dirname(__FILE__), '../../test/factories/attachable_factories')
World(FactoryGirl::Syntax::Methods)

require 'aruba/cucumber'

require 'capybara/poltergeist'

require 'capybara/dsl'
#Capybara.javascript_driver = :poltergeist
#Capybara.default_driver = :poltergeist



Before do
  # Configure where Aruba generates files.
  # You can't generate rails projects within rails projects', so it needs to be parallel to the browsercms project
  @aruba_dir = "../browsercms-tmp/aruba"
  @scratch_dir = "../browsercms-tmp/cached-bcms-project"
  @dirs = [@aruba_dir]

  # Generating projects takes a while, so give Aruba more time before it cuts things off.
  @aruba_timeout_seconds = 15

  # Must explicitly clean up the working directory before each test run (might be solved in later version of Aruba)
  FileUtils.rm_rf(@aruba_dir)

  # Run once per test run.
  if !$cleaned_cached_project
    FileUtils.rm_rf(@scratch_dir)
    $cleaned_cached_project = true
  end

end

# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a 
# newer version of cucumber-rails. Consider adding your own code to a new file 
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'cucumber/rails'

# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_selector = :css

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how 
# your application behaves in the production environment, where an error page will 
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
ActionController::Base.allow_rescue = false
$arel_silence_type_casting_deprecation=true

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

# Load the seed data once at the start of the test run.
# By doing this here, and using transaction strategy, we ensure the fastest possible tests.
DatabaseCleaner.clean_with :truncation
require File.join(File.dirname(__FILE__), '../../db/seeds.rb')


require 'test/unit/assertions'
World Test::Unit::Assertions
