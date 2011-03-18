module Cms
  module Generators
    class PortletGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      check_class_collision

      def create_portlet
        template 'portlet.rb', File.join('app/portlets', class_path, "#{portlet_file_name}.rb")
      end

      def create_helper
        template 'portlet_helper.rb', File.join('app/portlets/helpers', class_path, "#{portlet_file_name}_helper.rb")
      end

      def create_views
        template '_form.html.erb', File.join('app/views/portlets/', file_name, "_form.html.erb")
        template 'render.html.erb', File.join('app/views/portlets/', file_name, "render.html.erb")
      end

      def create_tests
        template 'unit_test.erb', File.join('test/unit/portlets', "#{portlet_file_name}_test.rb")
      end

      private

      def portlet_class_name
        "#{class_name}Portlet"
      end

      def portlet_file_name
        "#{file_name}_portlet"
      end
    end
  end
end

