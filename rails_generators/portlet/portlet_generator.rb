class PortletGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      portlet_class_name = "#{class_name}Portlet"
      portlet_file_name = "#{file_name}_portlet"
      
      # Check for class naming collisions.
      m.class_collisions class_path, portlet_class_name

      # Create the unit test for the model
      m.directory File.join('test/unit/portlets')
      m.template 'unit_test.erb', File.join('test/unit/portlets', "#{portlet_file_name}_test.rb")

      # Create the content block
      m.directory File.join('app/portlets', class_path)
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
