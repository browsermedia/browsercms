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

  def test_disable_enable
    @user = Factory(:user)

    assert_nil @user.expires_at
    assert !@user.expired?
    assert User.active.all.include?(@user)
    
    @user.disable!

    assert @user.expires_at <= Time.now
    assert @user.expired?
    assert !User.active.all.include?(@user)

    @user.enable!
    
    assert_nil @user.expires_at
    assert !@user.expired?
    assert User.active.all.include?(@user)
  end
end

class UserPermssionsTest < ActiveSupport::TestCase
  def setup
    @user = Factory(:user)
    @guest_group = Group.first(:conditions => {:code => "guest"})    
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
  
  def test_cms_user_permissions
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    @group.permissions << create_or_find_permission_named("edit_content")
    @group.permissions << create_or_find_permission_named("publish_content")
    @user.groups << @group
    @editable_section = Factory(:section, :parent => root_section, :name => "Editable")
    @group.sections << @editable_section
    @noneditable_section = Factory(:section, :parent => root_section, :name => "Not Editable")
    @editable_page = Factory(:page, :section => @editable_section)
    @noneditable_page = Factory(:page, :section => @noneditable_section)
    
    assert @user.able_to_edit?(@editable_section)
    assert !@user.able_to_edit?(@noneditable_section)
    assert @user.able_to_view?(@editable_page)
    assert @user.able_to_view?(@noneditable_page)
  end
  
  def test_non_cms_user_permissions
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "Registered User"))
    @user.groups << @group
    @editable_section = Factory(:section, :parent => root_section, :name => "Editable")
    @group.sections << @editable_section
    @noneditable_section = Factory(:section, :parent => root_section, :name => "Not Editable")
    @editable_page = Factory(:page, :section => @editable_section)
    @noneditable_page = Factory(:page, :section => @noneditable_section)

    assert !@user.able_to_edit?(@editable_section)
    assert !@user.able_to_edit?(@noneditable_section)
    assert @user.able_to_view?(@editable_page)
    assert !@user.able_to_view?(@noneditable_page)
  end
  
end

class GuestUserTest < ActiveSupport::TestCase
  def setup
    @user = User.guest
    @guest_group = Group.with_code("guest").first
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
  end
  
end