require 'test_helper'

ActiveRecord::Base.connection.instance_eval do
  drop_table(:external_users) if table_exists?(:external_users)
  create_table(:external_users) do |t| 
    t.string :name
    t.string :type
  end
end


EXTERNAL_USER_GROUPS = Hash.new {|hash,key| hash[key] = FactoryGirl.build(:group)}

class ExternalUser < ActiveRecord::Base
 #attr_accessible :name

end

class ExternalUserA < ExternalUser
  acts_as_cms_user
end

class ExternalUserB < ExternalUser
  acts_as_cms_user :groups => [EXTERNAL_USER_GROUPS['external-user-b']]
end

class ExternalUserC < ExternalUser
  acts_as_cms_user :groups => Proc.new{ |external_user_c| EXTERNAL_USER_GROUPS['external-user-c'] }
end

class ExternalUserD < ExternalUser
  acts_as_cms_user :groups => :get_groups

  def get_groups
    [EXTERNAL_USER_GROUPS['external-user-d1'], EXTERNAL_USER_GROUPS['external-user-d2']]
  end
end

class CmsUserTestCase < ActiveSupport::TestCase
  def test_responds_to
    @object = ExternalUserA.new(:name => "New Record")
    [:cms_groups, :viewable_sections, :permissions, :able_to_view?, :able_to?].each do |req_method|
      assert @object.respond_to?(req_method), "expected cms users to respond to #{req_method}"
    end
  end
  
  def test_default
    @object = ExternalUserA.new(:name => "New Record")
    assert_equal [Cms::Group.guest], @object.cms_groups
  end
  
  def test_array_option
    @object = ExternalUserB.new(:name => "New Record")
    assert_equal [EXTERNAL_USER_GROUPS['external-user-b']], @object.cms_groups
  end
  
  def test_proc_option
    @object = ExternalUserC.new(:name => "New Record")
    assert_equal [EXTERNAL_USER_GROUPS['external-user-c']], @object.cms_groups
  end
  
  def test_instance_method_option
    @object = ExternalUserD.new(:name => "New Record")
    assert_equal [EXTERNAL_USER_GROUPS['external-user-d1'], EXTERNAL_USER_GROUPS['external-user-d2']], @object.cms_groups
  end
  
end
