module Cms
  module Generators
    class TemplateGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)
      class_option :mobile, :type => :boolean, :default => false, :desc => "mobile?"

      def create_template
        if mobile?
          subdir = 'mobile'
        else
          subdir = 'templates'
        end
        template_dir = "app/views/layouts/#{subdir}"
        template 'template.erb', File.join(template_dir, "#{template_name}.html.erb")
      end

      private

      def mobile?
        options[:mobile]
      end

      def template_name
        file_name
      end
    end
  end
end
