@cli
Feature:
  Developers working in BrowserCMS projects should be able to generate blocks.

  Background:
    Given a BrowserCMS project named "petstore" exists
    And I cd into the project "petstore"

  Scenario: Create an content block for a project
    When I run `rails g cms:content_block product name:string price:string`
    Then the file "app/models/petstore/product.rb" should contain:
    """
    module Petstore
      class Product < ActiveRecord::Base
        acts_as_content_block
        content_module :products
      end
    end
    """
    And a file named "test/models/petstore/product_test.rb" should exist
    And the file "app/controllers/petstore/application_controller.rb" should contain:
    """
    module Petstore
      class ApplicationController < ActionController::Base
      end
    end
    """
    And the file "app/controllers/petstore/products_controller.rb" should contain:
    """
    module Petstore
      class ProductsController < Cms::ContentBlockController
      end
    end
    """
    And the file "app/views/petstore/products/render.html.erb" should contain:
    """
    <dt>Name:</dt><dd><%= show :name %></dd>
    """
    And the file "app/views/petstore/products/render.html.erb" should contain:
    """
    <dt>Price:</dt><dd><%= show :price %></dd>
    """
    And a migration named "create_petstore_products.rb" should contain:
    """
    class CreatePetstoreProducts < ActiveRecord::Migration
      def change
        create_content_table :products do |t|
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
    namespace :petstore do content_blocks :products end
    """
    And the file "config/routes.rb" should contain:
    """
    mount_browsercms
    """

  Scenario: Generated Dates
    When I run `rails g cms:content_block product fresh_until:date`
    Then the file "app/views/petstore/products/_form.html.erb" should contain:
    """
    <%= f.input :fresh_until, as: :date_picker %>
    """

  Scenario: Html Content
    When I run `rails g cms:content_block product content:html`
    Then the file "app/views/petstore/products/_form.html.erb" should contain:
    """
    <%= f.input :name, as: :name %>
    """
    And the file "app/views/petstore/products/_form.html.erb" should contain:
    """
    <%= f.input :content, as: :text_editor %>
    """

  # Date times should just be standard Rails widget
  Scenario: Date Time
    When I run `rails g cms:content_block sale runs_til:datetime`
    Then the file "app/views/petstore/sales/_form.html.erb" should contain:
    """
    <%= f.input :runs_til %>
    """

  Scenario: With Belongs To
    When I run `rails g cms:content_block product size:belongs_to`
    Then the file "app/models/petstore/product.rb" should contain:
    """
    belongs_to :size
    """
    And a migration named "create_petstore_products.rb" should contain:
    """
    t.belongs_to :size
    """
    Then the file "app/views/petstore/products/_form.html.erb" should contain:
    """
    <%= f.input :size %>
    """

  Scenario: With Categories
    When I run `rails g cms:content_block product category:category`
    Then the file "app/models/petstore/product.rb" should contain:
    """
    belongs_to_category
    """
    And a migration named "create_petstore_products.rb" should contain:
    """
    t.belongs_to :category
    """
    And the file "app/views/petstore/products/_form.html.erb" should contain:
    """
    <%= f.association :category, collection: categories_for('Product') %>
    """

  Scenario: With Html attributes
    When I run `rails g cms:content_block product content:html`
    Then a migration named "create_petstore_products.rb" should contain the following:
      | t.text :content, :size => (64.kilobytes + 1) |

  Scenario: Block names starting with 'do' should work
    When I run `rails g cms:content_block dog`
    And a migration named "create_petstore_dogs.rb" should contain:
    """
    class CreatePetstoreDogs < ActiveRecord::Migration
      def change
        create_content_table :dogs do |t|

          t.timestamps
        end
      end
    end
    """

