Feature:
  Users should be able to access CMS pages using user friendly routes, even when they have parameters.
  Page Routes allow for arbitrary URLs to be mapped to CMS pages.

  Background:
     Given I am logged in as a Content Editor

   Scenario: Multiple Pages
     Given there are 20 page routes
     When I am at /cms/page_routes
     Then I should see "Displaying 1 - 15 of 20"
     When I click on "next_page_link"
     Then I should see "Displaying 16 - 20 of 20"




