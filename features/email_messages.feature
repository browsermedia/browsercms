Feature: Email Messages
  CMS Admins should be able to see sent email messages in the UI

  Background:
    Given I am logged in as a Content Editor


  Scenario: Multiple Pages
    Given there are 20 send email messages
    When I am at /cms/email_messages
    Then I should see "Displaying 1 - 15 of 20"
    When I click on "next_page_link"
    Then I should see "Displaying 16 - 20 of 20"


