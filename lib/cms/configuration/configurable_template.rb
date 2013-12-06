module Cms
  module Configuration

    # Handles content that has configurable templates. Use the following rails configuration:
    #
    #   config.cms.templates['cms/form'] = 'my-form-layout'
    #   config.cms.templates['cms/sites/sessions_controller'] = :subpage
    module ConfigurableTemplate

      # Given a class name return a layout file path.
      # Looks in app.config.cms.templates first, then for the explicit_template
      def normalize_layout(klass, explicit_template)
        found = Rails.configuration.cms.templates[klass.name.underscore]
        if found
          "templates/#{found}"
        elsif explicit_template
          "templates/#{explicit_template}"
        else
          "templates/default"
        end
      end
    end
  end
end