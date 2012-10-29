# These should probably be pushed into factory girl factories as some point.
module ProtectedContentSteps
  def create_protected_user_section_group
    @protected_section = create(:section, :parent => root_section)
    @secret_group = create(:group, :name => "Secret")
    @secret_group.sections << @protected_section
    @privileged_user = create(:user, :login => "privileged")
    @privileged_user.groups << @secret_group
  end

  def create_protected_page(path="/secret")
    create_protected_user_section_group
    @page = create(:page,
                   :section => @protected_section,
                   :path => path,
                   :name => "Shhh... It's a Secret",
                   :template_file_name => "default.html.erb",
                   :publish_on_save => true)
  end


end
World(ProtectedContentSteps)


