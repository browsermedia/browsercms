@cli
Feature: Generate Attachments
  Developers should be able to generate blocks which use attachments.

  Background:
    Given a BrowserCMS project named "petstore" exists
    And I cd into the project "petstore"

  Scenario: Single Named Attachment
    When I run `rails g cms:content_block Product photo:attachment`
    Then the file "app/models/product.rb" should contain:
    """
    class Product < ActiveRecord::Base
      acts_as_content_block
      has_attachment :photo
    end
    """
    And a migration named "create_products.rb" should not contain:
    """
    t.attachment :photo
    """
    And the file "app/views/cms/products/render.html.erb" should contain:
    """
    <p><b>Photo:</b> <%= link_to attachment_path_for(@content_block.photo) %></p>
    """
    And the file "app/views/cms/products/_form.html.erb" should contain:
    """
    <%= f.cms_file_field :photo, :label => "Photo" %>
    """

  Scenario: Two Named Attachment
    When I run `rails g cms:content_block Product photo:attachment cover:attachment`
    Then the file "app/models/product.rb" should contain:
    """
    class Product < ActiveRecord::Base
      acts_as_content_block
      has_attachment :photo
      has_attachment :cover
    end
    """



