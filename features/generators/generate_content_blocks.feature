@cli
Feature: Generate Content Blocks
  Developers should be able to generate content blocks within projects to define new data structures.

  Background:

  Scenario: Create an content block for a project
    Given a BrowserCMS project named "petstore" exists
    When I run `rails g cms:content_block product name:string price:string` in the project
    Then I cd into the project "petstore"
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

  Scenario: Generate content block in a module
    Given I create a module named "bcms_widgets"
    When I cd into the project "bcms_widgets"
    And I run `rails g cms:content_block product name:string price:string`
    And the file "app/models/bcms_widgets/product.rb" should contain:
    """
    module BcmsWidgets
      class Product < ActiveRecord::Base
        acts_as_content_block
      end
    end
    """
    And the file "app/controllers/bcms_widgets/products_controller.rb" should contain:
    """
    module BcmsWidgets
      class ProductsController < Cms::ContentBlockController
      end
    end
    """
    And the file "app/views/bcms_widgets/products/render.html.erb" should contain:
    """
    <p><b>Name:</b> <%= @content_block.name %></p>
    <p><b>Price:</b> <%= @content_block.price %></p>
    """
    And a migration named "create_bcms_widgets_products.rb" should contain:
        """
        class CreateBcmsWidgetsProducts < ActiveRecord::Migration
          def change
            Cms::ContentType.create!(:name => "BcmsWidgets::Product", :group_name => "BcmsWidgets")
            create_content_table :bcms_widgets_products , :prefix=>false do |t|
              t.string :name
              t.string :price

              t.timestamps
            end
          end
        end
        """
    And the file "config/routes.rb" should contain:
    """
    BcmsWidgets::Engine.routes.draw do
      content_blocks :products

    end
    """





