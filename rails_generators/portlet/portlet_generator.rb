class PortletGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name

      # Create the directory for this portlet 
      m.directory File.join('app/portlets', class_path)

      # Create the content block
      m.template 'portlet.rb', File.join('app/portlets', class_path, "#{file_name}.rb")

      # Create the edit form for the content type
      portlet_name = file_name.sub(/_portlet/,'')
      m.directory File.join('app/views/portlets', portlet_name)
      m.template '_form.html.erb', File.join('app/views/portlets/', portlet_name, "_form.html.erb")
      m.template 'render.html.erb', File.join('app/views/portlets/', portlet_name, "render.html.erb")
    end
  end

  protected
    def banner
      "Usage: #{$0} #{spec.name} PortletName [field:type, field:type]"
    end

end
