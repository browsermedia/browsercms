Feature: Portlets
  In order to support dynamic content on my site
  As a content editor
  I want to be able to dynamically display content.

Background: A Homepage
  Given there is a homepage

Scenario: When logged in
  Given I am logged in as a Content Editor
  And there is a LoginPortlet on the homepage
  And I am on the homepage
  Then I should see Welcome, cmsadmin

Scenario: When logged out
  Given there is a LoginPortlet on the homepage
  And I am on the homepage
  Then I should see a Login Form