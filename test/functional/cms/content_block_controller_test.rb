require 'test_helper'

class Cms::SampleBlocksController < Cms::ContentBlockController
end

class PermissionsForContentBlockControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  tests Cms::SampleBlocksController

  # We're stubbing a lot because we *just* want to isolate the behaviour for checking permissions
  def setup
    given_there_is_a_content_type(Cms::SampleBlock)

    login_as_cms_admin
    @user = Cms::User.first
    @controller.stubs(:current_user).returns(@user)
    @controller.stubs(:render)
    @controller.stubs(:model_class).returns(Cms::SampleBlock)
    @controller.stubs(:set_default_category)
    @controller.stubs(:blocks_path).returns("/cms/sample_block")
    @controller.stubs(:block_path).returns("/cms/sample_block")
    @controller.stubs(:redirect_to_first).returns("/cms/sample_block")

    @block = stub_everything("block")
    @block.stubs(:class).returns(Cms::SampleBlock)
    @block.stubs(:as_of_draft_version).returns(@block)
    @block.stubs(:as_of_version).returns(@block)
    @block.stubs(:connected_pages).returns(stub(:all => stub))

    Cms::SampleBlock.stubs(:find).returns(@block)
    Cms::SampleBlock.stubs(:new).returns(@block)
    Cms::SampleBlock.stubs(:paginate)
  end

  def expect_access_denied
    @controller.expects(:render).with(has_entry(:status => 403))
  end

  def expect_success
    expect_access_denied.never
  end

  test "GET index allows any user" do
    expect_success
    get :index
  end

  test "GET show allows any user" do
    expect_success
    get :show, :id => 5
  end

  test "GET new allows any user" do
    expect_success
    get :new
  end

  test "POST create allows any user" do
    expect_success
    post :create
  end

  test "GET version allows any user" do
    expect_success
    get :version, :id => 5, :version => 3
  end

  test "GET versions allows any user" do
    expect_success
    get :versions, :id => 5
  end

  test "GET usages allows any user" do
    expect_success
    get :usages, :id => 5
  end

end
