module Cms::Extensions::SeleniumOnRails::FixtureLoader
  #We want to laod all fixtures and use our initial data instead of fixtures
  def available_fixures; {} end
  def load_fixtures(param)
    InitialData.load_data
  end
end
#TODO: Not working
#SeleniumOnRails::FixtureLoader.send(:include, Cms::Extensions::SeleniumOnRails::FixtureLoader)