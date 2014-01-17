require "minitest_helper"

describe Cms::ExternalUser do
  before do
    @default_attributes = {login: "test", email: 'p@p.com', external_data: {}}
  end

  let(:external_user) { Cms::ExternalUser.new(@default_attributes) }
  let(:authenticated_user) { Cms::ExternalUser.authenticate('test', 'tests') }

  it "must be valid" do
    external_user.valid?.must_equal true
  end

  describe 'Known ruby 1.9.3/Rails4 bug' do
    if RUBY_VERSION == '1.9.3'
      it "prevents creation if external_data isn't specified" do
        @default_attributes.delete(:external_data)
        proc { Cms::ExternalUser.create!(@default_attributes) }.must_raise NoMethodError
      end
    end
  end

  describe '#password_changable?' do
    it "should not be changeable" do
      external_user.password_changeable?.must_equal false
    end
  end
  describe '.save' do
    it "should persist" do
      external_user.save!
      external_user.persisted?.must_equal true
    end
  end

  describe ".permitted_params" do
    it "should include group_ids but not passwords" do
      Cms::ExternalUser.permitted_params.must_include(:group_ids => [])
    end
    it "should include group_ids but not passwords" do
      Cms::ExternalUser.permitted_params.wont_include(:password)
    end
  end

  describe '.authenticate' do
    it "should create the account if it doesn't exist" do
      u = Cms::ExternalUser.authenticate('my-username', 'Specs')
      u.persisted?.must_equal true
    end

    it "should return the existing user if it exists" do
      existing = Cms::ExternalUser.authenticate('my-username', 'Specs')
      same = Cms::ExternalUser.authenticate('my-username', 'Specs')
      existing.must_equal same
    end

    it "should assign user to Guest group by default" do
      given_there_is_a_guest_group

      ext_user = Cms::ExternalUser.authenticate('my-username', 'Specs')
      ext_user.groups.must_include Cms::Group.guest
    end

    it "should allow for extra info to be passed in" do
      user = Cms::ExternalUser.authenticate('stan.marsh', 'southpark-crm', {first_name: "Stan", external_data: {city: 'South Park'}})
      user.first_name.must_equal 'Stan'
      user.external_data[:city].must_equal 'South Park'
    end

    it "should overwrite old attributes on subsequent authentications" do
      first_authentication = Cms::ExternalUser.authenticate('stan.marsh', 'southpark-crm')
      first_authentication.first_name.must_be_nil
      second_authentication = Cms::ExternalUser.authenticate('stan.marsh', 'southpark-crm', {first_name: "Stan"})
      second_authentication.first_name.must_equal 'Stan'
    end
  end

  describe '#external_data' do
    it "should persist random extra attributes" do
      external_user.external_data = {country: 'US', shoe_size: 12}
      external_user.save!
      external_user.reload.external_data[:country].must_equal 'US'
      external_user.external_data[:shoe_size].must_equal 12
    end
  end

  describe '#authorize' do
    let(:member_group) { create(:group, code: 'member') }
    let(:nonmember_group) { create(:group, code: 'nonmember') }

    before do
      ensure_groups_exist = member_group, nonmember_group
    end

    it "should assign groups to user" do
      authenticated_user.authorize('member')
      authenticated_user.groups.must_include member_group
    end

    it "should allow multiple groups" do
      authenticated_user.authorize('member', 'nonmember')
      authenticated_user.groups.must_include member_group
      authenticated_user.groups.must_include nonmember_group
    end

    it "should overwrite previous groups" do
      authenticated_user.authorize('member')
      authenticated_user.authorize('nonmember')
      authenticated_user.groups.wont_include member_group
      authenticated_user.groups.must_include nonmember_group
    end
  end

  describe '#permissions' do
    it "should include edit permission" do
      user_with_edit_content.permissions.collect { |p| p.name }.must_include('edit_content')
    end

    it "should able to :edit_content" do
      user_with_edit_content.must_be :able_to?, :edit_content
    end

    def user_with_edit_content
      return @user_with_edit_content if @user_with_edit_content
      g = create(:content_editor_group)
      g.permissions.collect { |p| p.name }.must_include('edit_content')
      @user_with_edit_content = Cms::ExternalUser.new(@default_attributes)
      @user_with_edit_content.groups << g
      @user_with_edit_content.save!
      @user_with_edit_content
    end
  end


end
