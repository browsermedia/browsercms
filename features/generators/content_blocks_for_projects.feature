@cli
Feature:
  Developers working in BrowserCMS projects should be able to generate blocks.

  Background:
    Given a BrowserCMS project named "petstore" exists
    And I cd into the project "petstore"

  Scenario: Create an content block for a project
    When I run `rails g cms:content_block product name:string price:string`
    And the file "app/models/product.rb" should contain:
    """
    class Product < ActiveRecord::Base
      acts_as_content_block
    end
    """
    And a file named "test/unit/product_test.rb" should exist
    And the file "app/controllers/cms/products_controller.rb" should contain:
    """
    class Cms::ProductsController < Cms::ContentBlockController
    end
    """
    And the file "app/views/cms/products/render.html.erb" should contain:
    """
    <p><b>Name:</b> <%= @content_block.name %></p>
    <p><b>Price:</b> <%= @content_block.price %></p>
    """
    And a migration named "create_products.rb" should contain:
    """
    class CreateProducts < ActiveRecord::Migration
      def change
        Cms::ContentType.create!(:name => "Product", :group_name => "Product")
        create_content_table :products , :prefix=>false do |t|
          t.string :name
          t.string :price

          t.timestamps
        end
      end
    end
    """
    And the file "config/routes.rb" should contain:
    """
    Petstore::Application.routes.draw do
      namespace :cms  do content_blocks :products end

      mount_browsercms
    """

  Scenario: With Belongs To
    When I run `rails g cms:content_block product size:belongs_to`
    Then the file "app/models/product.rb" should contain:
    """
    class Product < ActiveRecord::Base
      acts_as_content_block
      belongs_to :size
    end
    """
    And a migration named "create_products.rb" should contain:
    """
    t.belongs_to :size
    """

  Scenario: With Categories
    When I run `rails g cms:content_block product category:category`
    Then the file "app/models/product.rb" should contain:
    """
    class Product < ActiveRecord::Base
      acts_as_content_block
      belongs_to_category
    end
    """
    And a migration named "create_products.rb" should contain:
    """
    t.belongs_to :category
    """

  Scenario: With Attachments
    When I run `rails g cms:content_block product attachment:attachment`
    Then the file "app/models/product.rb" should contain:
    """
    class Product < ActiveRecord::Base
      acts_as_content_block
      belongs_to_attachment

      def set_attachment_file_path
        # The default behavior is use /attachments/file.txt for the attachment path,
        # assuming file.txt was the name of the file the user uploaded
        # You should override this with your own strategy for setting the attachment path
        super
      end

      def set_attachment_section
        # The default behavior is to put all attachments in the root section
        # Override this method if you would like to change that
        super
      end
    end
    """
    And a migration named "create_products.rb" should contain the following:
      | t.belongs_to :attachment      |
      | t.integer :attachment_version |

  Scenario: With Html attributes
    When I run `rails g cms:content_block product content:html`
    Then a migration named "create_products.rb" should contain the following:
      | t.text :content, :size => (64.kilobytes + 1) |



