module Cms
  module Generators
    class TemplateGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)

      def create_template
        template_dir = 'app/views/layouts/templates'
#        empty_directory template_dir
        template 'template.erb', File.join(template_dir, "#{template_name}.html.erb")
      end

      private

      def template_name
        file_name
      end
    end
  end
end
