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
  end
  
end