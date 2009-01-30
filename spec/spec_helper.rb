# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.expand_path(File.dirname(__FILE__) + "/spec_extensions")
require 'spec'
require 'spec/rails'
include Cms::Authentication::Controller

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  
  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  config.include FixtureReplacement

  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Example::Configuration and Spec::Runner
end

# Sets the current user in the session from the user fixtures.
def login_as(user)
  User.current = user
end

def login_as_user(attrs={})
  login_as admin_user
end

def authorize_as(user)
  @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'monkey') : nil
end

# rspec
def mock_user
  user = mock_model(User, :id => 1,
    :login  => 'user_name',
    :name   => 'U. Surname',
    :to_xml => "User-in-XML", :to_json => "User-in-JSON", 
    :errors => [])
  user
end

def log(msg)
  Rails.logger.info msg
end

def root_section
  root = Section.root.first
  return root unless root.nil?
  root = create_section(:name => "My Site", :root => true)
  root.groups << guest_group
  root
end

def admin_user(attrs={})
  user = User.find_by_login("cmsadmin")
  return user if user
  user = create_user({:login => "cmsadmin"}.merge(attrs))
  group = create_group(:group_type => create_group_type(:cms_access => true))
  group.permissions << create_permission(:name => "administrate")
  group.permissions << create_permission(:name => "edit_content")
  group.permissions << create_permission(:name => "publish_content")
  user.groups << group
  user
end

def create_system_pages
  @system_section = create_section(:parent => root_section)
  @error_template = create_page_template(:name => "Error", :file_name => "templates/error")
  create_page(:name => "Not Found", :path => "/system/not_found", :template => @error_template, :publish_on_save => true, :section => @system_section)  
  create_page(:name => "Access Denied", :path => "/system/access_denied", :template => @error_template, :publish_on_save => true, :section => @system_section)  
  create_page(:name => "Server Error", :path => "/system/server_error", :template => @error_template, :publish_on_save => true, :section => @system_section)  
end

def guest_group
  Group.find_by_code("guest") || create_group(:code => "guest")
end

def register_type(content_type_class)
  create_content_type(:name => content_type_class.to_s)
end

def controller_setup
  include Cms::PathHelper
  integrate_views  
  before { login_as_user }
end

def mock_file(options = {})
  file_upload_object({:original_filename => "test.jpg", 
    :content_type => "image/jpeg", :rewind => true,
    :size => "99", :read => "01010010101010101"}.merge(options))
end

def streaming_file_contents(response)
  #The body of a streaming response is a proc
  streamer = response.body
  streamer.class.should == Proc

  #Create a dummy object for the proc to write to
  output = Object.new
  def output.write(contents); (@contents ||= "") << contents end
  
  #run the proc
  streamer.call(response, output)  
  
  #run what it wrote to the dummy object
  output.instance_variable_get("@contents")
end

#Takes a list of the names of instance variables to "reset"
#Each instance variable will be set to a new instance
#That is found by looking that object by id
def reset(*args)
  args.each do |v|
    val = instance_variable_get("@#{v}")
    instance_variable_set("@#{v}", val.class.find(val.id))
  end
end

def file_upload_object(options)
  file = ActionController::UploadedTempfile.new(options[:original_filename])
  open(file.path, 'w') {|f| f << options[:read]}
  file.original_path = options[:original_filename]
  file.content_type = options[:content_type]
  file
end