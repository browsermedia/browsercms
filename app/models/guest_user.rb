class GuestUser < User
  
  def initialize(attributes={})
    super({:login => "guest", :first_name => "Anonymous", :last_name => "User"}.merge(attributes))
    @guest = true
  end
    
  def able_to?(name)
    group && !!(group.permissions.find_by_name(name))
  end
  
  def able_to_view?(page)
    group && !!(group.sections.include?(page.section))
  end
  
  def able_to_edit?(section)
    false
  end
  
  def group
    @group ||= Group.find_by_code("guest")
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
  def save
    false
  end
  
end