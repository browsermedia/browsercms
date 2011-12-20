Feature: Generators
  BrowserCMS provides generators for common CMS tasks.

  Background:
    Given a BrowserCMS project named "petstore" exists

  Scenario: Create an content block for a project
    When I run `rails generate cms:content_block product name:string price:string` in the project
    Then a project file named "app/models/product.rb" should contain "class Product < ActiveRecord::Base"
    And a project file named "app/models/product.rb" should contain "acts_as_content_block"
    And a project file named "app/controllers/cms/products_controller.rb" should contain "class Cms::ProductsController < Cms::ContentBlockController"
    And a project file named "app/views/cms/products/render.html.erb" should contain "@content_block.name"
    And a project file named "app/views/cms/products/render.html.erb" should contain "@content_block.price"
    And a migration named "create_products.rb" should be created

  # Should namespace the classes under Cms::
  Scenario: Generate content block for Core CMS project
    When I generate a block using a namespace




