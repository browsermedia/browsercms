module SeleniumOnRails::FixtureLoader
  #We want to laod all fixtures and use our initial data instead of fixtures
  def available_fixures; {} end
  def load_fixtures(param)
    clear_tables ActiveRecord::Base.connection.tables.join(", ")
    InitialData.load_data
    {}
  end
end