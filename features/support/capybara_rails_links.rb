module Capybara
  module RailsLinks

    # Find a link that should be a PUT request and click it.
    # Only works with RackTest driver, and works around the fact that Rails javascript PUT isn't updated by Javascript.
    # @param [String] name_or_selector Same options as click_link(name_or_selector)
    def click_put_link(name_or_selector)
      link = find_link(name_or_selector)
      page.driver.put link[:href]
    end
  end

end
World(Capybara::RailsLinks)
