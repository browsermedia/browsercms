require "minitest_helper"

describe Cms::User do

  let(:user){build(:user)}
  describe '.change_password' do
    it "should change" do
      user = create(:user, login: 'testuser')
      Cms::User.change_password('testuser', 'newpassword')
      user.reload.valid_password?('newpassword').must_equal true
    end
  end

  describe "#generate_password" do
    it "should generate a valid random password" do
      user = Cms::User.new
      user.new_password
      user.password.wont_be_nil
      user.password.length.must_equal 8
    end
  end

  describe '#source' do
    it "should return hardcoded value" do
      user.source.must_equal "CMS Users"
    end
  end
  describe '#password_confirmation' do
    it 'should exist' do
      user = Cms::User.new()
      user.password_confirmation = "t"
      user.password_confirmation.must_equal "t"
    end
  end

  describe '.permitted_params' do
    it "should allow :group_ids" do
      assert Cms::User.permitted_params.include?(:group_ids => []), "Allow for bulk submitted group_ids as a collection."
    end

    it "should allow passwords" do
      Cms::User.permitted_params.must_include :password
    end
  end

  describe '#active_for_authentication?' do

    it "should not authenticate expired users" do
      expired_user = create(:user, expires_at: 1.day.ago, login: 'testuser', password: 'testuser')
      expired_user.active_for_authentication?.must_equal false
    end

    it "should authenticate users" do
      active_user = create(:user)
      active_user.active_for_authentication?.must_equal true
    end

  end
  describe '#save!' do
    it "should encrypt new passwords" do
      user = Cms::User.create!(login: "test", email: 'test@test.com', password: 'testtest', password_confirmation: 'testtest')
      user.encrypted_password.wont_be :blank?
    end
  end
end
