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
  
  describe "authorization" do
    before do
      @user = new_user
      @have = new_permission(:name => "have")
      @havenot = new_permission(:name => "have_not")
      @group_a = new_group
      @group_b = new_group
      
      @group_a.permissions << @have
      @group_b.permissions << @havenot
      
      @user.groups<<@group_a
    end
    
    it "should have permission" do
      @user.has_permission("have").should be_true
    end
    
    it "should not have permission" do
      @user.has_permission("havenot").should be_false
    end
  end
end