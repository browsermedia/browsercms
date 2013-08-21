Feature:
  Visitors on mobile devices should see mobile templates when they visit pages.

  Background:
    Given a page exists at /mobile-page with a mobile ready template

  Scenario: Full vs Mobile toggle
    Given a bug: Full vs Mobile toggle does not toggle locally between full and mobile versions.

  Scenario: Desktop Visitor sees Desktop template
    Given a user is browsing the desktop site
    When they request /mobile-page
    Then they should see the desktop content

  Scenario: Browsing mobile site pages
    Given a user is browsing the mobile site
    When they request /mobile-page
    Then they should see the mobile template

  Scenario: Browsing the desktop site with a mobile browser
    Given a user is browsing the desktop site
    And they are using an iPhone
    When they request /mobile-page
    Then they should see the desktop content

  Scenario: Browsing a page on mobile site without a mobile template
    Given a page exists at /not-mobile with a desktop only template
    And a user is browsing the mobile site
    When they request /not-mobile
    Then they should see the desktop content

  Scenario: Editors can see mobile version of page
    Given a cms editor is logged in
    When they request /mobile-page
    Then they should see the desktop content
    When they request /mobile-page?template=mobile
    Then they should see the mobile template

  Scenario: Mobile 'mode' is sticky
    Given a page exists at /another-page with a mobile ready template
    And a cms editor is logged in
    When they request /another-page?template=mobile
    Then they request /mobile-page
    Then they should see the mobile template

  Scenario: Disable Mobile mode
    Given a page exists at /another-page with a mobile ready template
    And a cms editor is logged in
    When they request /mobile-page?template=mobile
    Then they request /mobile-page?template=full
    Then they should see the desktop content

  Scenario: Guests can't request mobile versions of page
    Given a user is browsing the desktop site
    When they request /mobile-page?template=mobile
    Then they should see the desktop content

  Scenario: Toolbar for mobile ready pages
    Given a cms editor is logged in
    And they request /mobile-page
    Then they should see the mobile toggle

  Scenario: Toolbar for pages without mobile templates
    Given a cms editor is logged in
    And a page exists at /not-mobile with a desktop only template
    When they request /not-mobile
    Then they should not see the mobile toggle