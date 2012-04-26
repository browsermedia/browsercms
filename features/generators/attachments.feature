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
    <p><b>Photo:</b> <%= link_to "Photo", attachment_path_for(@content_block.photo) %></p>
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

  Scenario: Multiple Attachments
    When I run `rails g cms:content_block Product photos:attachments`
    Then the file "app/models/product.rb" should contain:
    """
    class Product < ActiveRecord::Base
      acts_as_content_block
      has_many_attachments :photos
    end
    """
    And a migration named "create_products.rb" should not contain:
    """
    t.attachments :photos
    """
    And the file "app/views/cms/products/render.html.erb" should contain:
    """
    <p><b>Attachments:</b> <%= attachment_viewer @content_block %></p>
    """
    And the file "app/views/cms/products/_form.html.erb" should contain:
    """
    <%= f.cms_attachment_manager %>
    """

  Scenario: Multiple Attachments with different names
    When I run `rails g cms:content_block Product photos:attachments documents:attachments`
    Then the file "app/models/product.rb" should contain:
    """
    class Product < ActiveRecord::Base
      acts_as_content_block
      has_many_attachments :photos
      has_many_attachments :documents
    end
    """
    And a migration named "create_products.rb" should not contain:
    """
    t.attachments :photos
    t.attachments :documents
    """
    And the file "app/views/cms/products/render.html.erb" should not contain:
    """
    <p><b>Attachments:</b> <%= attachment_viewer @content_block %></p>
    <p><b>Attachments:</b> <%= attachment_viewer @content_block %></p>
    """
    And the file "app/views/cms/products/_form.html.erb" should not contain:
    """
    <%= f.cms_attachment_manager %>
    <%= f.cms_attachment_manager %>
    """
