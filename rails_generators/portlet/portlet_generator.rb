class PortletGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      portlet_class_name = "#{class_name}Portlet"
      portlet_file_name = "#{file_name}_portlet"
      
      # Check for class naming collisions.
      m.class_collisions class_path, portlet_class_name

      # Create the directory for this portlet 
      m.directory File.join('app/portlets', class_path)

      # Create unit test dir if needed
      m.directory File.join('test/unit/portlets')

      # Create the unit test for the model
      m.template 'unit_test.erb', File.join('test/unit/portlets', "#{portlet_file_name}_test.rb")

      # Create the content block
      m.template 'portlet.rb', File.join('app/portlets', class_path, "#{portlet_file_name}.rb")

      # Create the edit form for the content type
      m.directory File.join('app/views/portlets', file_name)
      m.template '_form.html.erb', File.join('app/views/portlets/', file_name, "_form.html.erb")
      m.template 'render.html.erb', File.join('app/views/portlets/', file_name, "render.html.erb")
    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name} PortletName [field:type, field:type]"
    end

end
