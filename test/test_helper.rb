ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require 'action_view/test_case'

# Allows Generators to be unit tested
require "rails/generators/test_case"

# I'm not sure why ANY of these FactoryGirl requires are necessary at all.
require 'factory_girl'
require 'factories'

require 'mock_file'
require 'support/factory_helpers'
require 'support/engine_controller_hacks'

class ActiveSupport::TestCase

  include FactoryHelpers

  # Add more helper methods to be used by all tests here...
  require File.dirname(__FILE__) + '/test_logging'
  include TestLogging
  require File.dirname(__FILE__) + '/custom_assertions'
  include CustomAssertions

  #----- Test Macros -----------------------------------------------------------
  class << self
    def should_validate_presence_of(options)
      factory_name = options.keys.first
      fields = options[factory_name]
      fields.each do |f|
        define_method("test_validates_presence_of_#{f}") do
          model = Factory.build(factory_name, f => nil)
          assert !model.valid?
          assert_has_error_on model, f, "can't be blank"
        end
      end
    end

    def should_validate_uniqueness_of(options)
      class_name = options.keys.first
      fields = options[class_name]
      fields.each do |f|
        define_method("test_validates_uniqueness_of_#{f}") do
          existing_model = Factory(class_name)
          model = Factory.build(class_name, f => existing_model.send(f))
          assert !model.valid?
          assert_has_error_on model, f, "has already been taken"
        end
      end
    end
  end

  def self.subclasses_from_module(module_name)
    subclasses = []
    mod = module_name.constantize
    if mod.class == Module
      mod.constants.each do |module_const_name|
        begin
          klass_name = "#{module_name}::#{module_const_name}"
          klass = klass_name.constantize
          if klass.class == Class
            subclasses << klass
            subclasses += klass.send(:descendants).collect { |x| x.respond_to?(:constantize) ? x.constantize : x }
          else
            subclasses += subclasses_from_module(klass_name)
          end
        rescue NameError
          raise $!
          puts $!.inspect
        end
      end
    end
    return subclasses
  end

  #----- Fixture/Data related helpers ------------------------------------------

  def admin_user
    cms_users(:user_1)
  end

  def create_or_find_permission_named(name)
    Cms::Permission.named(name).first || Factory(:permission, :name => name)
  end

  def guest_group
    Cms::Group.guest || Factory(:group, :code => Group::GUEST_CODE)
  end

  def login_as(user)
    @request.session[:user_id] = user ? user.id : nil
  end

  def login_as_cms_admin
    given_there_is_a_cmsadmin if Cms::User.count == 0
    admin = Cms::User.first
    login_as(admin)
    admin
  end


  # Takes a list of the names of instance variables to "reset"
  # Each instance variable will be set to a new instance
  # That is found by looking that object by id
  def reset(*args)
    args.each do |v|
      val = instance_variable_get("@#{v}")
      instance_variable_set("@#{v}", val.class.find(val.id))
    end
  end

  # @3.4.x-merge Remove me once Cucumber coverage is added

  # Fixtures add incorrect Section/Section node data. We don't want to replace fixtures AGAIN (this is handled in CMS 3.3)
  # so we can just clean it out using this method where needed to avoid test breakage.
  def remove_all_sitemap_fixtures_to_avoid_bugs
    #Section.delete_all
    #SectionNode.delete_all
    #Page.delete_all
  end

  # @3.4.x-merge Remove me once Cucumber coverage is added

  # Create a 'faux' sitemap which will work for tests (avoids need for fixtures)
  def given_a_site_exists
    @root = root_section
    @homepage = Factory(:public_page, :name => "Home", :section => @root, :path => "/")
    @system_section = Factory(:public_section, :name => "System", :parent => @root, :path => "/system")
    @not_found_page = Factory(:public_page, :name => "Not Found", :section => @system_section, :path => Cms::ErrorPages::NOT_FOUND_PATH)
    @access_denied_page = Factory(:public_page, :name => "Access Denied", :section => @system_section, :path => Cms::ErrorPages::FORBIDDEN_PATH)
    @error_page = Factory(:public_page, :name => "Server Error", :section => @system_section, :path => Cms::ErrorPages::SERVER_ERROR_PATH)
  end
end

ActionController::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path

# This might be removable in later versions of Rails 3.1.x which correctly add the routes to functional controllers
require 'support/rails_3_1_routes_hack'
Cms::Engine.load_engine_routes

module Cms::ControllerTestHelper
  def self.included(test_case)
    test_case.send(:include, Cms::PathHelper)
  end

  def request
    @request
  end

  def streaming_file_contents
    #The body of a streaming response is a proc
    streamer = @response.body
#    assert_equal Proc, streamer.class

#Create a dummy object for the proc to write to
    output = Object.new

    def output.write(contents)
      (@contents ||= "") << contents
    end

    #run the proc
    streamer.call(@response, output)

    #return what it wrote to the dummy object
    output.instance_variable_get("@contents")
  end
end

module Cms::IntegrationTestHelper
  def login_as(user, password = "password")
    get login_url
    assert_response :success
    post login_url, :login => user.login, :password => password
    assert_response :redirect
    assert flash[:notice]
  end

  def login_as_cms_admin
    login_as(Cms::User.first, "cmsadmin")
  end
end

def create_testing_table(name)
  ActiveRecord::Base.connection.instance_eval do
    drop_table(name) if table_exists?(name)
    create_table(name)
  end
end

