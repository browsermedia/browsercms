@cli
Feature: Generate Attachments
  Developers should be able to generate blocks which use attachments.

  Background:
    Given a BrowserCMS project named "petstore" exists
    And I cd into the project "petstore"

  Scenario: Single Named Attachment
    When I run `rails g cms:content_block Product photo:attachment`
    Then the file "app/models/petstore/product.rb" should contain:
    """
    has_attachment :photo
    """
    And a migration named "create_petstore_products.rb" should not contain:
    """
    t.attachment :photo
    """
    And the file "app/views/petstore/products/render.html.erb" should contain:
    """
    <dt>Photo:</dt><dd><%= link_to "Photo", attachment_path_for(@content_block.photo) %></dd>
    """
    And the file "app/views/petstore/products/_form.html.erb" should contain:
    """
    <%= f.input :photo, as: :file_picker %>
    """

  Scenario: Two Named Attachment
    When I run `rails g cms:content_block Product photo:attachment cover:attachment`
    Then the file "app/models/petstore/product.rb" should contain the following content:
      | has_attachment :photo |
      | has_attachment :cover |

  Scenario: Multiple Attachments
    When I run `rails g cms:content_block Product photos:attachments`
    Then the file "app/models/petstore/product.rb" should contain:
    """
    has_many_attachments :photos
    """
    And a migration named "create_petstore_products.rb" should not contain:
    """
    t.attachments :photos
    """
    And the file "app/views/petstore/products/render.html.erb" should contain:
    """
    <dt>Attachments:</dt><dd><%= attachment_viewer @content_block %></dd>
    """
    And the file "app/views/petstore/products/_form.html.erb" should contain:
    """
    <%= f.cms_attachment_manager %>
    """

  Scenario: Multiple Attachments with different names
    When I run `rails g cms:content_block Product photos:attachments documents:attachments`
    Then the file "app/models/petstore/product.rb" should contain the following content:
      | has_many_attachments :photos    |
      | has_many_attachments :documents |
    And a migration named "create_petstore_products.rb" should not contain:
    """
    t.attachments :photos
    t.attachments :documents
    """
    And the file "app/views/petstore/products/render.html.erb" should not contain:
    """
    <dt>Attachments:</dt><dd><%= attachment_viewer @content_block %></dd>
    <dt>Attachments:</dt><dd><%= attachment_viewer @content_block %></dd>
    """
    And the file "app/views/petstore/products/_form.html.erb" should not contain:
    """
    <%= f.cms_attachment_manager %>
    <%= f.cms_attachment_manager %>
    """
