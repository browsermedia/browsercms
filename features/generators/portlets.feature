@cli
Feature:
  Developers working in BrowserCMS projects should be able to generate portlets.

  Background:
    Given a BrowserCMS project named "petstore" exists
    And I cd into the project "petstore"

  Scenario: Generate a portlet
    When I run `rails g cms:portlet Events body`
    Then the file "app/portlets/events_portlet.rb" should contain:
    """
    description "TODO: Provide a suitable description for this portlet."
    """
    And the file "app/views/portlets/events/_form.html.erb" should contain:
    """
    <%= f.input :name %>
    <%= f.input :body %>
    <%= f.input :template, as: :template_editor %>
    """

