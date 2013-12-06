module Cms

  # Add to controllers to allow them to behave like pages. A newer version of Acts::ContentPage
  module ContentPage
    extend ActiveSupport::Concern

    included do
      helper_method :cms_template
      layout :determine_layout
      class_attribute :template_name
      class_attribute :template_options

      include Cms::Authentication::Controller
      include Cms::PageHelper
      helper Cms::PageHelper
      helper Cms::RenderingHelper
      helper Cms::MenuHelper
      include Cms::Configuration::ConfigurableTemplate
    end

    module ClassMethods

      # Specify which CMS template should be used for this controller. Works similarly to ActionController::Base#layout.
      # Will use the named template from the appropriate directory (typically app/views/layouts/templates)
      #
      # The default CMS layout will be used if no template is specified.
      #
      # @example
      #   template :subpage, only: [:new, :create]
      #   template :subpage, except: [:new, :create]
      #   template :subpage, only: [:new, :create]
      #
      # @param [Symbol] template_name Name of the template with no directory prefixes or file type. (i.e. subpage, homepage)
      # @param [Hash] options (Optional)
      # @option options [Array<Symbol>] :only The actions to apply the template to.
      # @option options [Array<Symbol>] :exception The actions to not apply the template to.
      def template(template_name, options={})
        self.template_name = template_name.to_s
        self.template_options = options
      end

    end

    # Returns the page template that should be used to render this page.
    def cms_template
      "layouts/#{normalize_layout(self.class, self.class.template_name)}"
    end

    def content_page_layout
      'cms/content_page'
    end

    protected

    def template_options
      self.class.template_options
    end

    def use_template?
      if template_name.blank?
        false
      elsif template_options.empty?
        true
      elsif template_options[:only] && template_options[:only].include?(action_name.to_sym)
        true
      elsif template_options[:except] && !template_options[:except].include?(action_name.to_sym)
        true
      else
        false
      end
    end

    def determine_layout
      use_template? ? content_page_layout : 'cms/application'
    end
  end
end