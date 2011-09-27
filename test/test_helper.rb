ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

require 'action_view/test_case'
#require 'mocha'

# Allows Generators to be unit tested
require "rails/generators/test_case"

require 'factory_girl'
require 'factories'
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
    def should_validate_presence_of(*fields)
      fields.each do |f|
        class_name = name.sub(/Test$/, '')
        define_method("test_validates_presence_of_#{f}") do
          model = Factory.build(class_name.underscore.to_sym, f => nil)
          assert !model.valid?
          assert_has_error_on model, f, "can't be blank"
        end
      end
    end

    def should_validate_uniqueness_of(*fields)
      fields.each do |f|
        class_name = name.sub(/Test$/, '')
        define_method("test_validates_uniqueness_of_#{f}") do
          existing_model = Factory(class_name.underscore.to_sym)
          model = Factory.build(class_name.underscore.to_sym, f => existing_model.send(f))
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

  require 'mock_file'
  # Creates a TempFile attached to an uploaded file. Used to test attachments
  def file_upload_object(options)
    Cms::MockFile.new_file(options[:original_filename], options[:content_type])
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


  # Creates a sample uploaded JPG file with binary data.
  def mock_file(options = {})
    file_upload_object({:original_filename => "foo.jpg",
                        :content_type => "image/jpeg"}.merge(options))
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

