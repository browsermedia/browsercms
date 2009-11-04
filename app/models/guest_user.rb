#
# Guests are a special user that represents a non-logged in user. The main reason to create an explicit
# instance of this type of user is so that the permissions a Guest user can have can be set via the Admin interface.
#
# Every request that a non-logged in user makes will use this User's permissions to determine what they can/can't do.
#
class GuestUser < User

  def initialize(attributes={})
    super({:login => Group::GUEST_CODE, :first_name => "Anonymous", :last_name => "User"}.merge(attributes))
    @guest = true
  end
    
  def able_to?(*name)
    group && group.permissions.count(:conditions => ["name in (?)", name.map(&:to_s)]) > 0
  end
  
  def able_to_view?(page)
    group && !!(group.sections.include?(page.section))
  end
  
  def able_to_edit?(section)
    false
  end
  
  def group
    @group ||= Group.guest
  end
  
  def groups
    [group]
  end
  
  #You shouldn't be able to save a guest user
  def update_attribute(name, value)
    false
  end
  def update_attributes(attrs={})
    false
  end
  def save(perform_validation=true)
    false
  end
  
end