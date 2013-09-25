ENV["RAILS_ENV"] = "test"
require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
require "rails/test_help"
require "minitest/spec"
require "minitest/unit"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
require File.expand_path("../../test/factories/factories", __FILE__)
require File.expand_path("../../test/factories/attachable_factories", __FILE__)

require 'minitest/reporters'
MiniTest::Reporters.use!

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

class Minitest::Spec
  after :each do
    DatabaseCleaner.clean
  end
  include FactoryGirl::Syntax::Methods
  include FactoryHelpers
end
