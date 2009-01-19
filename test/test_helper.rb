ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  include FixtureReplacement
  
  #----- Custom Assertions -----------------------------------------------------
  
  def assert_file_exists(file_name, message=nil)
    assert File.exists?(file_name), 
      (message || "Expected File '#{file_name}' to exist, but it does not")
  end  
  
  def assert_not_valid(object, message=nil)
    assert !object.valid?, 
      (message || 
        "#{object.class.name.titleize} is valid, but it should not be")
  end
  
  def assert_has_error_on_base(object, error_message=nil, message=nil)
    assert_has_error_on(object, :base, error_message, message)
  end
  
  def assert_has_error_on(object, field, error_message=nil, message=nil)
    e = object.errors.on(field.to_sym)
    if e.is_a?(String)
      e = [e]
    elsif e.nil?
      e = []
    end
    if error_message
      assert e.include?(error_message), 
        "Expected errors on #{field} #{e} to include '#{error_message}', but it does not"
    else
      assert !e.empty?, "Expected errors on #{field}, but there are none"
    end
  end
  
  #----- Fixture/Data related helpers ------------------------------------------

  def guest_group
    Group.find_by_code("guest") || create_group(:code => "guest")
  end  

  def root_section
    root = Section.root.first
    return root unless root.nil?
    root = create_section(:name => "My Site", :root => true)
    root.groups << guest_group
    root
  end
  
end
