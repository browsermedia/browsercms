module Cms::Extensions::SeleniumOnRails::FixtureLoader
  #We want to laod all fixtures and use our initial data instead of fixtures
  def available_fixures; {} end
  def load_fixtures(param)
    Rails.logger.info "Loading Data..."
    InitialData.load_data
  end
end
SeleniumOnRails::FixtureLoader.send(:include, Cms::Extensions::SeleniumOnRails::FixtureLoader)