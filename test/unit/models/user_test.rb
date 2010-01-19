require File.join(File.dirname(__FILE__), '/../../test_helper')

class UserTest < ActiveSupport::TestCase

  should_validate_presence_of :login, :password, :password_confirmation
  should_validate_uniqueness_of :login

  def test_authenticate
    @user = Factory(:user)
    assert_equal @user, User.authenticate(@user.login, @user.password)
    assert_nil User.authenticate(@user.login, 'FAIL')
  end

  def test_authenticate_expired_user
    @user = Factory(:user)
    @user.disable!
    assert_nil User.authenticate(@user.login, @user.password)
  end

  def test_expiration
    @user = Factory.build(:user)
    assert_nil @user.expires_at
    assert_nil @user.expires_at_formatted
    assert !@user.expired?

    @user.expires_at = 1.day.from_now
    assert !@user.expired?

    @user.expires_at = Time.now
    assert @user.expired?

    @user.expires_at = 1.day.ago
    assert @user.expired?
  end

  def test_active
    @user = Factory(:user)
    assert User.active.all.include?(@user)

    @user.update_attribute(:expires_at, 1.year.from_now)
    assert User.active.all.include?(@user)
  end

  test "Disable should work regardless of time zone" do
    @user = Factory(:user)

    Time.zone = "UTC"
    @user.disable!
    assert !User.active.all.include?(@user)

    user2 = Factory(:user)
    Time.zone = "Eastern Time (US & Canada)"
    user2.disable!
    assert !User.active.all.include?(user2)

  end

  def test_disable_enable
    @user = Factory(:user)

    assert_nil @user.expires_at
    assert !@user.expired?
    assert User.active.all.include?(@user)

    assert @user.disable!

    assert @user.expires_at <= Time.now.utc
    assert @user.expired?
    assert !User.active.all.include?(@user)

    @user.enable!

    assert_nil @user.expires_at
    assert !@user.expired?
    assert User.active.all.include?(@user)
  end

  test "email validation" do
    @user = Factory(:user)
    assert @user.valid?

    valid_emails = ['t@test.com', 'T@test.com', 'test@somewhere.mobi', 'test@somewhere.tv', 'joe_blow@somewhere.co.nz', 'joe_blow@somewhere.com.au', 't@t-t.co']
    valid_emails.each do |email|
      @user.email = email
      assert @user.valid?
    end

    invalid_emails = ['', '@test.com', '@test', 'test@test', 'test@somewhere', 'test@somewhere.', 'test@somewhere.x', 'test@somewhere..']
    invalid_emails.each do |email|
      @user.email = email
      assert !@user.valid?
    end
  end
  test "full name or login" do
    login = 'robbo'
    fn = 'Bob'
    ln = 'Smith'
    u = User.new(:login => 'robbo')
    assert_equal login, u.full_name_or_login
    u.first_name = fn
    assert_equal fn, u.full_name_or_login
    u.last_name = ln
    assert_equal fn + ' ' + ln, u.full_name_or_login

  end
end

class UserAbleToViewTest < ActiveSupport::TestCase

  test "User able_to_view? with String path" do
    non_admin = GroupType.create!(:cms_access=>false)
    group = Factory(:group, :group_type=>non_admin)
    public_user = Factory(:user)
    public_user.groups<< group
    public_user.save!

    section = Factory(:section, :path=>"/members", :name=>"Members")
    section.groups << group
    section.save!

    assert public_user.able_to_view?("/members")
  end

  test "User can't view a nil section" do
    user = User.new

    Section.expects(:find_by_path).with("/members").returns(nil)
    user.expects(:able_to_view_without_paths?).never

    assert_raise ActiveRecord::RecordNotFound do
      user.able_to_view?("/members")
    end

  end

  test "Users with cmsaccess?" do
    @non_admin = GroupType.create!(:cms_access=>true)
    @group = Factory(:group, :group_type=>@non_admin)
    @public_user = Factory(:user)
    @public_user.groups<< @group
    @public_user.save!

    assert(@public_user.cms_access?, "")
  end

  test "cms_access? determines if a user is considered to have cmsadmin privledges or not." do
    user = User.new
    assert(!user.cms_access?, "")
  end


end

class UserPermissionsTest < ActiveSupport::TestCase
  def setup
    @user = Factory(:user)
    @guest_group = Group.guest
  end

  def test_user_permissions
    @have = Factory(:permission, :name => "do something the group has permission to do")
    @havenot = Factory(:permission, :name => "do something the group does not have permission to do")
    @group_a = Factory(:group)
    @group_b = Factory(:group)

    @group_a.permissions << @have
    @group_b.permissions << @havenot

    @user.groups << @group_a

    assert @user.able_to?("do something the group has permission to do")
    assert !@user.able_to?("do something the group does not have permission to do")
  end

  test "cms user access to nodes" do
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    @user.groups << @group

    @modifiable_section = Factory(:section, :parent => root_section, :name => "Modifiable")
    @non_modifiable_section = Factory(:section, :parent => root_section, :name => "Not Modifiable")

    @group.sections << @modifiable_section

    @modifiable_page = Factory(:page, :section => @modifiable_section)
    @non_modifiable_page = Factory(:page, :section => @non_modifiable_section)

    @modifiable_link = Factory(:link, :section => @modifiable_section)
    @non_modifiable_link = Factory(:link, :section => @non_modifiable_section)

    assert @user.able_to_modify?(@modifiable_section)
    assert !@user.able_to_modify?(@non_modifiable_section)

    assert @user.able_to_modify?(@modifiable_page)
    assert !@user.able_to_modify?(@non_modifiable_page)

    assert @user.able_to_modify?(@modifiable_link)
    assert !@user.able_to_modify?(@non_modifiable_link)
  end

  test "cms user access to connectables" do
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    @user.groups << @group

    @modifiable_section = Factory(:section, :parent => root_section, :name => "Modifiable")
    @non_modifiable_section = Factory(:section, :parent => root_section, :name => "Not Modifiable")

    @group.sections << @modifiable_section

    @modifiable_page = Factory(:page, :section => @modifiable_section)
    @non_modifiable_page = Factory(:page, :section => @non_modifiable_section)

    @all_modifiable_connectable = stub(
            :class => stub(:content_block? => true, :connectable? => true),
            :connected_pages => [@modifiable_page])
    @some_modifiable_connectable = stub(
            :class => stub(:content_block? => true, :connectable? => true),
            :connected_pages => [@modifiable_page, @non_modifiable_page])
    @none_modifiable_connectable = stub(
            :class => stub(:content_block? => true, :connectable? => true),
            :connected_pages => [@non_modifiable_page])

    assert @user.able_to_modify?(@all_modifiable_connectable)
    assert !@user.able_to_modify?(@some_modifiable_connectable)
    assert !@user.able_to_modify?(@none_modifiable_connectable)
  end

  test "cms user access to non-connectable content blocks" do
    @content_block = stub(:class => stub(:content_block? => true))
    assert @user.able_to_modify?(@content_block)
  end

  test "non cms user access to nodes" do
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "Registered User"))
    @user.groups << @group

    @modifiable_section = Factory(:section, :parent => root_section, :name => "Modifiable")
    @group.sections << @modifiable_section
    @non_modifiable_section = Factory(:section, :parent => root_section, :name => "Not Modifiable")

    @modifiable_page = Factory(:page, :section => @modifiable_section)
    @non_modifiable_page = Factory(:page, :section => @non_modifiable_section)

    assert !@user.able_to_modify?(@modifiable_section)
    assert !@user.able_to_modify?(@non_modifiable_section)

    assert @user.able_to_view?(@modifiable_page)
    assert !@user.able_to_view?(@non_modifiable_page)
  end

  test "cms user with no permissions should still be able to view pages" do
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    @user.groups << @group

    @page = Factory(:page)
    assert @user.able_to_view?(@page)
  end

  test "cms user who can edit content" do
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    @group.permissions << create_or_find_permission_named("edit_content")
    @user.groups << @group

    node = stub

    @user.stubs(:able_to_modify?).with(node).returns(true)
    assert @user.able_to_edit?(node)
    assert !@user.able_to_publish?(node)

    @user.stubs(:able_to_modify?).with(node).returns(false)
    assert !@user.able_to_edit?(node)
    assert !@user.able_to_publish?(node)
  end

  test "cms user who can publish content" do
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    @group.permissions << create_or_find_permission_named("publish_content")
    @user.groups << @group

    node = stub

    @user.stubs(:able_to_modify?).with(node).returns(true)
    assert !@user.able_to_edit?(node)
    assert @user.able_to_publish?(node)

    @user.stubs(:able_to_modify?).with(node).returns(false)
    assert !@user.able_to_edit?(node)
    assert !@user.able_to_publish?(node)
  end

end

class GuestUserTest < ActiveSupport::TestCase
  def setup
    @user = User.guest
    @guest_group = Group.guest
    @public_page = Factory(:page, :section => root_section)
    @protected_section = Factory(:section, :parent => root_section)
    @protected_page = Factory(:page, :section => @protected_section)
  end

  def test_guest
    assert @user.guest?
    assert_equal @guest_group, @user.group
    assert @user.groups.include?(@guest_group)
    assert !@user.able_to?("do anything global")
    assert @user.able_to_view?(@public_page)
    assert !@user.able_to_view?(@protected_page)
    assert !@user.cms_access?
  end

  test "override viewable sections for the guest group" do
    @user.expects(:viewable_sections).returns([@protected_section])
    assert_equal Section, @protected_section.class
    assert(@protected_section.is_a?(Section), "")
    assert @user.able_to_view?(@protected_section)
  end

  test "GuestUser can't view a nil section" do
    user = GuestUser.new

    Section.expects(:find_by_path).with("/members").returns(nil)

    assert_raise ActiveRecord::RecordNotFound do
      user.able_to_view?("/members")
    end

  end

  test "Guest User able_to_view? with String path" do
    section = Factory(:section, :path=>"/members", :name=>"Members")
    section.groups << @guest_group
    section.save!

    assert @user.able_to_view?("/members")

  end

  test "Group.guest is in fixtures." do
    assert_not_nil Group.guest, "Expected to be in the database for tests."
  end

end
