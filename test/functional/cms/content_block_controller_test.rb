require 'test_helper'

class Dummy::SampleBlocksController < Cms::ContentBlockController
end

class PermissionsForContentBlockControllerTest < ActionController::TestCase
  include Cms::ControllerTestHelper
  tests Dummy::SampleBlocksController

  # We're stubbing a lot because we *just* want to isolate the behaviour for checking permissions
  def setup

    login_as_cms_admin
    @user = Cms::User.first
    @controller.stubs(:current_user).returns(@user)
    @controller.stubs(:render)
    @controller.stubs(:model_class).returns(Dummy::SampleBlock)
    @controller.stubs(:set_default_category)
    @controller.stubs(:engine_aware_path).returns("/cms/sample_block")
    @controller.stubs(:redirect_to_first).returns("/cms/sample_block")

    @block = stub_everything("block")
    @block.stubs(:class).returns(Dummy::SampleBlock)
    @block.stubs(:as_of_draft_version).returns(@block)
    @block.stubs(:as_of_version).returns(@block)
    @block.stubs(:connected_pages).returns(stub(:all => stub))

    Dummy::SampleBlock.stubs(:find).returns(@block)
    Dummy::SampleBlock.stubs(:new).returns(@block)
    Dummy::SampleBlock.stubs(:paginate)
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

end
