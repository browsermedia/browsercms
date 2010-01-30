class TemplateGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|

      template_name = "#{file_name}"

      m.directory File.join('app/views/layouts/templates')
      m.template 'template.erb', File.join('app/views/layouts/templates', "#{template_name}.html.erb")

    end
  end

  protected
  def banner
    "Usage: #{$0} #{spec.name} template_name"
  end
end