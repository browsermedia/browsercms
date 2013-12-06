require 'test_helper'

module Cms
  class UserTest < ActiveSupport::TestCase

    def setup
      @need_at_least_one_enabled_user = create(:user)
      @user = create(:user)
    end

    should_validate_presence_of :user => [:login, :password]
    should_validate_uniqueness_of :user => [:login]

    def test_expiration
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
      assert Cms::User.active.to_a.include?(@user)

      @user.update_attribute(:expires_at, 1.year.from_now)
      assert Cms::User.active.to_a.include?(@user)
    end

    test "Disable should work regardless of time zone" do
      Time.zone = "UTC"
      @user.disable!
      assert !Cms::User.active.to_a.include?(@user)

      user2 = create(:user)
      Time.zone = "Eastern Time (US & Canada)"
      user2.disable!
      assert !Cms::User.active.to_a.include?(user2)

    end

    def test_disable_enable
      assert_nil @user.expires_at
      assert !@user.expired?

      assert Cms::User.active.to_a.include?(@user)

      assert @user.disable!

      assert @user.expires_at <= Time.now.utc
      assert @user.expired?
      assert !Cms::User.active.to_a.include?(@user)

      @user.enable!

      assert_nil @user.expires_at
      assert !@user.expired?
      assert Cms::User.active.to_a.include?(@user)
    end

    test "email validation" do
      assert @user.valid?

      valid_emails = ['t@test.com', 'T@test.com', 'test@somewhere.mobi', 'test@somewhere.tv', 'joe_blow@somewhere.co.nz', 'joe_blow@somewhere.com.au', 't@t-t.co', 'test@somewhere.x', 'test@somewhere..']
      valid_emails.each do |email|
        @user.email = email
        assert @user.valid?
      end

      invalid_emails = ['', '@test.com', '@test', 'test@test', 'test@somewhere', 'test@somewhere.']
      invalid_emails.each do |email|
        @user.email = email
        assert !@user.valid?, "This email '#{email}' is not considered valid."
      end
    end

    test "full name or login" do
      login = 'robbo'
      fn = 'Bob'
      ln = 'Smith'
      u = build(:user, :login => 'robbo', :first_name => nil, :last_name => nil)
      assert_equal login, u.full_name_or_login
      u.first_name = fn
      assert_equal fn, u.full_name_or_login
      u.last_name = ln
      assert_equal fn + ' ' + ln, u.full_name_or_login

    end
  end

  class UserAbleToViewTest < ActiveSupport::TestCase

    test "Registered User able_to_view? with String path" do
      registered_user = Cms::User.new
      viewable_section = Cms::Section.new
      Cms::Section.expects(:find_by_path).with("/members").returns(viewable_section)
      registered_user.expects(:viewable_sections).returns([viewable_section])

      assert registered_user.able_to_view?("/members")
    end

    test "User can't view a nil section" do
      user = Cms::User.new

      Cms::Section.expects(:find_by_path).with("/members").returns(nil)
      user.expects(:able_to_view_without_paths?).never

      assert_raise ActiveRecord::RecordNotFound do
        user.able_to_view?("/members")
      end

    end

    test "Users with cmsaccess?" do
      @non_admin = Cms::GroupType.create!(:cms_access => true)
      @group = create(:group, :group_type => @non_admin)
      @public_user = create(:user)
      @public_user.groups<< @group
      @public_user.save!

      assert(@public_user.cms_access?, "")
    end

    test "cms_access? determines if a user is considered to have cmsadmin privledges or not." do
      user = Cms::User.new
      assert(!user.cms_access?, "")
    end
  end

  class PageEdittingPermissions < ActiveSupport::TestCase
    def setup
      @content_editor = create(:content_editor) # Create first, so it will have permission to edit root section

      given_a_site_exists
      @private_section = create(:section, :parent => root_section)
      @private_page = create(:public_page, :section => @private_section)
      @editable_page = create(:public_page, :section => root_section)
    end

    test "#modifiable_sections" do
      assert @content_editor.modifiable_sections.include?(root_section)
      refute @content_editor.modifiable_sections.include?(@private_section)
    end

    test "#able_to_modify?" do
      assert_equal false, @content_editor.able_to_modify?(@private_page)
      assert_equal true, @content_editor.able_to_modify?(@editable_page)
    end

    test "#able_to_edit" do
      assert_equal false, @content_editor.able_to_edit?(@private_page)
      assert_equal true, @content_editor.able_to_edit?(@editable_page)
    end

    test "#able_to_publish?" do
      assert_equal false, @content_editor.able_to_publish?(@private_page)
      assert_equal true, @content_editor.able_to_publish?(@editable_page)
    end
  end

  class UserPermissionsTest < ActiveSupport::TestCase
    def setup
      @user = create(:user)
      @guest_group = Cms::Group.guest
    end

    def test_user_permissions
      @have = create(:permission, :name => "do something the group has permission to do")
      @havenot = create(:permission, :name => "do something the group does not have permission to do")
      @group_a = create(:group)
      @group_b = create(:group)

      @group_a.permissions << @have
      @group_b.permissions << @havenot

      @user.groups << @group_a

      assert @user.able_to?("do something the group has permission to do")
      assert !@user.able_to?("do something the group does not have permission to do")
    end

    test "cms user access to nodes" do
      @group = create(:group, :name => "Test", :group_type => create(:group_type, :name => "CMS User", :cms_access => true))
      @user.groups << @group

      @modifiable_section = create(:section, :parent => root_section, :name => "Modifiable")
      @non_modifiable_section = create(:section, :parent => root_section, :name => "Not Modifiable")

      @group.sections << @modifiable_section

      @modifiable_page = create(:page, :section => @modifiable_section)
      @non_modifiable_page = create(:page, :section => @non_modifiable_section)

      @modifiable_link = create(:link, :section => @modifiable_section)
      @non_modifiable_link = create(:link, :section => @non_modifiable_section)

      assert @user.able_to_modify?(@modifiable_section)
      assert !@user.able_to_modify?(@non_modifiable_section)

      assert @user.able_to_modify?(@modifiable_page)
      assert !@user.able_to_modify?(@non_modifiable_page)

      assert @user.able_to_modify?(@modifiable_link)
      assert !@user.able_to_modify?(@non_modifiable_link)
    end

    test "cms user access to connectables" do
      @group = create(:group, :name => "Test", :group_type => create(:group_type, :name => "CMS User", :cms_access => true))
      @user.groups << @group

      @modifiable_section = create(:section, :parent => root_section, :name => "Modifiable")
      @non_modifiable_section = create(:section, :parent => root_section, :name => "Not Modifiable")

      @group.sections << @modifiable_section

      @modifiable_page = create(:page, :section => @modifiable_section)
      @non_modifiable_page = create(:page, :section => @non_modifiable_section)

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
      @group = create(:group, :name => "Test", :group_type => create(:group_type, :name => "Registered User"))
      @user.groups << @group

      @modifiable_section = create(:section, :parent => root_section, :name => "Modifiable")
      @group.sections << @modifiable_section
      @non_modifiable_section = create(:section, :parent => root_section, :name => "Not Modifiable")

      @modifiable_page = create(:page, :section => @modifiable_section)
      @non_modifiable_page = create(:page, :section => @non_modifiable_section)

      assert !@user.able_to_modify?(@modifiable_section)
      assert !@user.able_to_modify?(@non_modifiable_section)

      assert @user.able_to_view?(@modifiable_page)
      assert !@user.able_to_view?(@non_modifiable_page)
    end

    test "cms user with no permissions should still be able to view pages" do
      @group = create(:group, :name => "Test", :group_type => create(:group_type, :name => "CMS User", :cms_access => true))
      @user.groups << @group

      @page = create(:page)
      assert @user.able_to_view?(@page)
    end

    test "cms user who can publish content" do
      @group = create(:group, :name => "Test", :group_type => create(:group_type, :name => "CMS User", :cms_access => true))
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
      @guest_group = given_there_is_a_guest_group
      @guest_user = Cms::User.guest
      @public_page = create(:page, :section => root_section)
      @protected_section = create(:section, :parent => root_section)
      @protected_page = create(:page, :section => @protected_section)
    end

    def test_guest
      assert @guest_user.guest?
      assert_equal @guest_group, @guest_user.group
      assert @guest_user.groups.include?(@guest_group)
      assert !@guest_user.able_to?("do anything global")
      assert !@guest_user.able_to_view?(@protected_page)
      assert !@guest_user.cms_access?
    end

    test "guest users should be able to see pages in public sections" do
      root_section.allow_groups = :all
      assert @guest_user.able_to_view?(@public_page)
    end

    test "override viewable sections for the guest group" do
      @guest_user.expects(:viewable_sections).returns([@protected_section])
      assert_equal Cms::Section, @protected_section.class
      assert(@protected_section.is_a?(Cms::Section), "")
      assert @guest_user.able_to_view?(@protected_section)
    end

    test "GuestUser can't view a nil section" do
      user = Cms::GuestUser.new

      Cms::Section.expects(:find_by_path).with("/members").returns(nil)

      assert_raise ActiveRecord::RecordNotFound do
        user.able_to_view?("/members")
      end

    end

    test "Guest User able_to_view? with String path" do
      expected_section = Cms::Section.new

      Cms::Section.expects(:find_by_path).with("/members").returns(expected_section)
      @guest_user.expects(:viewable_sections).returns([expected_section])

      assert @guest_user.able_to_view?("/members")

    end

    test "Group.guest should be created during setup." do
      assert_not_nil Cms::Group.guest, "Expected to be in the database for tests in this class."
    end

  end
end