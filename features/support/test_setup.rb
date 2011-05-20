require 'cms/data_loader'

AfterConfiguration do
  DatabaseCleaner.clean
  Cms::DataLoader.silent_mode = true
  require File.join(File.dirname(__FILE__), '../../db/seeds.rb')
end


require 'factory_girl'
require File.join(File.dirname(__FILE__), '../../test/factories.rb')
