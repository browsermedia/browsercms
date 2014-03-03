@cli
Feature: Generate Content Blocks
  Developers should be able to generate content blocks within projects to define new data structures.

  Background:
    Given I create a module named "bcms_widgets"
    When I cd into the project "bcms_widgets"

  Scenario: Generate content block in a module
    When I run `rails g cms:content_block product name:string price:string`
    And the file "app/models/bcms_widgets/product.rb" should contain:
    """
    module BcmsWidgets
      class Product < ActiveRecord::Base
        acts_as_content_block
        content_module :products
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
    <dt>Name:</dt><dd><%= show :name %></dd>
    """
    And the file "app/views/bcms_widgets/products/render.html.erb" should contain:
    """
    <dt>Price:</dt><dd><%= show :price %></dd>
    """
    And a migration named "create_bcms_widgets_products.rb" should contain:
    """
    class CreateBcmsWidgetsProducts < ActiveRecord::Migration
      def change
        create_content_table :bcms_widgets_products do |t|
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







