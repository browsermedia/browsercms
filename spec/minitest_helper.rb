ENV["RAILS_ENV"] = "test"
require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
require "rails/test_help"
require "minitest/spec"
require "minitest/unit"
$arel_silence_type_casting_deprecation=true

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
