module Cms
  module Generators
    class TemplateGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)

      def create_template
       template 'template.erb', File.join('app/views/layouts/templates', "#{template_name}.html.erb")
      end

      private

      def template_name
        file_name
      end
    end
  end
end
