ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rails/test_help"
require "minitest/spec"
#require "minitest/autorun"
require "minitest/unit"

#ENV["RAILS_ENV"] = "test"
#require File.expand_path("../dummy/config/environment.rb", __FILE__)
#
#require "minitest/autorun"
#require "minitest/rails"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
require 'factories/factories'
require 'factories/attachable_factories'

require 'minitest/reporters'
MiniTest::Reporters.use!

# Uncomment if you want Capybara in accceptance/integration tests
# require "minitest/rails/capybara"

# Uncomment if you want awesome colorful output
# require "minitest/pride"

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

class Minitest::Spec
  after :each do
    DatabaseCleaner.clean
  end
  include FactoryGirl::Syntax::Methods
  include FactoryHelpers
end

#class MiniTest::Rails::ActiveSupport::TestCase
#
#  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
#  #fixtures :all
#
#  # Add more helper methods to be used by all tests here...
#end

# Do you want all existing Rails tests to use MiniTest::Rails?
# Comment out the following and either:
# A) Change the require on the existing tests to `require "minitest_helper"`
# B) Require this file's code in test_helper.rb

#MiniTest::Rails.override_testunit!
