@cli
Feature:
  Developers working in BrowserCMS projects should be able to generate blocks.

  Background:
    Given a BrowserCMS project named "petstore" exists
    And I cd into the project "petstore"

  Scenario: Create an content block for a project
    When I run `rails g cms:content_block product name:string price:string`
    Then the file "app/models/product.rb" should contain:
    """
    class Product < ActiveRecord::Base
      acts_as_content_block
      content_module :products
    end
    """
    And a file named "test/models/product_test.rb" should exist
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
        create_content_table :products, :prefix=>false do |t|
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
    """
    And the file "config/routes.rb" should contain:
    """
    namespace :cms  do content_blocks :products end
    """
    And the file "config/routes.rb" should contain:
    """
    mount_browsercms
    """

  Scenario: Generated Dates
    When I run `rails g cms:content_block product fresh_until:date`
    Then the file "app/views/cms/products/_form.html.erb" should contain:
    """
    <%= f.input :fresh_until, as: :date_picker %>
    """

  Scenario: Html Content
    When I run `rails g cms:content_block product content:html`
    Then the file "app/views/cms/products/_form.html.erb" should contain:
    """
    <%= f.input :name, as: :cms_text_field %>
    """
    And the file "app/views/cms/products/_form.html.erb" should contain:
    """
    <%= f.input :content, as: :text_editor %>
    """

  # Date times should just be standard Rails widget
  Scenario: Date Time
    When I run `rails g cms:content_block sale runs_til:datetime`
    Then the file "app/views/cms/sales/_form.html.erb" should contain:
    """
    <%= f.input :runs_til %>
    """

  Scenario: With Belongs To
    When I run `rails g cms:content_block product size:belongs_to`
    Then the file "app/models/product.rb" should contain:
    """
    class Product < ActiveRecord::Base
      acts_as_content_block
      content_module :products
      belongs_to :size
    end
    """
    And a migration named "create_products.rb" should contain:
    """
    t.belongs_to :size
    """
    Then the file "app/views/cms/products/_form.html.erb" should contain:
    """
    <%= f.input :size %>
    """

  Scenario: With Categories
    When I run `rails g cms:content_block product category:category`
    Then the file "app/models/product.rb" should contain:
    """
    class Product < ActiveRecord::Base
      acts_as_content_block
      content_module :products
      belongs_to_category
    end
    """
    And a migration named "create_products.rb" should contain:
    """
    t.belongs_to :category
    """
    And the file "app/views/cms/products/_form.html.erb" should contain:
    """
    <%= f.association :category, collection: categories_for('Product') %>
    """

  Scenario: With Html attributes
    When I run `rails g cms:content_block product content:html`
    Then a migration named "create_products.rb" should contain the following:
      | t.text :content, :size => (64.kilobytes + 1) |

  Scenario: Block names starting with 'do' should work
    When I run `rails g cms:content_block dog`
    And a migration named "create_dogs.rb" should contain:
    """
    class CreateDogs < ActiveRecord::Migration
      def change
        create_content_table :dogs, :prefix=>false do |t|

          t.timestamps
        end
      end
    end
    """

