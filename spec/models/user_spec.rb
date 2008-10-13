# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  it_should_validate_presence_of :login, :password, :password_confirmation
  it_should_validate_uniqueness_of :login

  describe ".authenticate" do
    before { @user = create_user }
    it "should return the user when passed a valid login/password, " do
      User.authenticate(@user.login, @user.password).should == @user
    end
    it "should return nil when passed and incorrect login/password" do
      User.authenticate(@user.login, 'FAIL').should be_nil
    end

    describe "with expired users" do
      before(:each) do
        @user.disable!
      end
      it "should not authenticate expired users" do
        User.authenticate(@user.login, @user.password).should be_nil
      end
    end
  end

  describe "expires_at" do
    before(:each) do
      @user = new_user
    end

    it "should return nill from expires_at_formatted if expires_at is nil" do
      @user.expires_at = nil
      @user.expires_at_formatted.should be_nil
    end

    describe "as related to expired" do
      it "should not be marked as expired if set in the future" do
        @user.expires_at = 1.day.from_now
        @user.expired?.should be_false
      end

      it "should be expired if = now" do
        @user.expires_at = Time.now
        @user.expired?.should be_true
      end
      it "should be expired if set a while ago" do
        @user.expires_at = 1.day.ago
        @user.expired?.should be_true
      end
    end

    describe ".disable" do
      it "should mark as user as expired right now" do
        @user.expires_at.should be_nil
        @user.disable
        @user.expires_at.should <= Time.now
      end
      it "should be expired" do
        @user.disable
        @user.expired?.should be_true
      end
    end

    describe "enable" do
      before(:each) do
        @user.disable
      end
      it "should mark as user as enabled." do
        @user.enable
        @user.expires_at.should be_nil
      end
    end
  end

  describe "named scopes" do
    before(:each) do
      @user = create_user(:expires_at => 1.day.ago)
    end
    it "should find not find expired user" do
      users = User.active
      users.should be_empty
    end
  end
end

describe "A User" do
  before do
    @user = create_user
    @guest_group = create_group(:code => "guest")
  end
  it "should not be a guest" do
    @user.should_not be_guest
  end
  it "should not be in the guest group" do
    @user.groups.should_not include(@guest_group)
  end
  it "should be able to be added to groups by group_ids" do
    group = create_group(:name => "foo")
    @user.group_ids = [group.id]
    @user.save
    @user.groups.should == [group]
  end
  it "should be able to be added to groups by <<" do
    group = create_group(:name => "foo")
    @user.groups << group
    @user.groups.should == [group]
  end
  describe "in a group" do
    before do
      @have = new_permission(:name => "do something the group has permission to do")
      @havenot = new_permission(:name => "do something the group does not have permission to do")
      @group_a = new_group
      @group_b = new_group

      @group_a.permissions << @have
      @group_b.permissions << @havenot

      @user.groups << @group_a  
    end
    
    it "should be able to do something the group has permission to do" do
      @user.should be_able_to("do something the group has permission to do")
    end
    
    it "should not be able to do something the groups does not have permission to do" do
      @user.should_not be_able_to("do something the group does not have permission to do")
    end  
  end
  describe "in a CMS User group with one section" do
    before do
      @group = create_group(:name => "Test", :group_type => "CMS User")
      @user.groups << @group
      @editable_section = create_section(:parent => root_section, :name => "Editable")
      @group.sections << @editable_section
      @noneditable_section = create_section(:parent => root_section, :name => "Not Editable")
      @editable_page = create_page(:section => @editable_section)
      @noneditable_page = create_page(:section => @noneditable_section)
    end
    it "should be able to edit the section" do
      @user.should be_able_to_edit(@editable_section)
    end
    it "should not be able to edit a section that is not in the group" do
      @user.should_not be_able_to_edit(@noneditable_section)
    end
    it "should be able to view a page in the section" do
      @user.should be_able_to_view(@editable_page)      
    end
    it "should be able to view a page not in the section" do
      @user.should be_able_to_view(@noneditable_page)      
    end
  end
  describe "in a non-CMS User group with one section" do
    before do
      @group = create_group(:name => "Test", :group_type => "Registered User")
      @user.groups << @group
      @editable_section = create_section(:parent => root_section, :name => "Editable")
      @group.sections << @editable_section
      @noneditable_section = create_section(:parent => root_section, :name => "Not Editable")
      @editable_page = create_page(:section => @editable_section)
      @noneditable_page = create_page(:section => @noneditable_section)
    end
    it "should not be able to edit the section" do
      @user.should_not be_able_to_edit(@editable_section)
    end
    it "should not be able to edit a section that is not in the group" do
      @user.should_not be_able_to_edit(@noneditable_section)
    end
    it "should be able to view a page in the section" do
      @user.should be_able_to_view(@editable_page)      
    end
    it "should not be able to view a page not in the section" do
      @user.should_not be_able_to_view(@noneditable_page)      
    end
  end  
end

describe "The Guest User" do
  before do
    @guest_group = create_group(:code => "guest")
    @public_page = create_page(:section => root_section)
    @protected_section = create_section(:parent => root_section)
    @protected_page = create_page(:section => @protected_section)
  end
  it "should be guest" do
    User.guest.should be_guest
  end
  it "should be in the guest group" do
    User.guest.group.should == @guest_group
    User.guest.groups.should include(@guest_group)
  end
  it "should not be able to do anything global" do
    User.guest.should_not be_able_to("do anything global")
  end
  it "should be able to view pages that are in a section in the guest group" do
    User.guest.should be_able_to_view(@public_page)
  end
  it "should not be able to view pages that are in a section that is not in the guest group" do
    User.guest.should_not be_able_to_view(@protected_page)
  end
  describe "who is a search bot" do
    before do
      @search_bot_group = create_group(:code => "search_bot")
      @search_bot_root = create_section(:parent => root_section)
      @search_bot_root.groups << @search_bot_group
      @search_bot_page = create_page(:section => @search_bot_root)
      @search_bot = User.guest({ :login => "search_bot", :first_name => "browsermedia webcrawler" })
    end
    it "should be a guest and a search bot" do
      @search_bot.should be_guest
      @search_bot.should be_search_bot
    end
    it "should not be able to do anything global" do
      @search_bot.should_not be_able_to("do anything global")
    end
    it "should be able to view pages that are in a section in the search_bot group" do
      @search_bot.should be_able_to_view(@search_bot_page)
    end
    it "should not be able to view pages that are in a section that is not in the search_bot group" do
      @search_bot.should_not be_able_to_view(@public_page)
      @search_bot.should_not be_able_to_view(@protected_page)
    end
  end
end

