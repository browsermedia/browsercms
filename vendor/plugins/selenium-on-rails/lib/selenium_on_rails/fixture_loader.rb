require 'test/unit'
require 'active_record/fixtures'

module SeleniumOnRails::FixtureLoader
  include SeleniumOnRails::Paths
  
  #This has been modified from the original selenium on rails plugin
  #Could not get this to work as a monkey patch
  def available_fixtures
    {} 
  end
  
  def load_fixtures(param)
    clear_tables ActiveRecord::Base.connection.tables.join(", ")
    InitialData.load_data
    {}
  end

  def clear_tables tables
    table_names = tables.split /\s*,\s*/
    connection = ActiveRecord::Base.connection 
    table_names.each do |table|
      connection.execute "DELETE FROM #{table}" 
    end
    table_names
  end
  
end
