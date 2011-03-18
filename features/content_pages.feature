Feature: Content Pages
  In order to see a website
  As an guest
  I want a CMS that services content pages

Background: Blank CMS Install
  Given there is a homepage

Scenario: Homepage
  Given I am on the homepage
  Then I should see a page titled "THIS TEST IS PASSING WHEN IT SHOULDN'T"

Scenario: Homepage exists
  Given I am on the homepage
  Then the homepage should exist