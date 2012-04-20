module Cms
  module Behaviors
    # Assumes the 'extended' class is an instance of ActiveModel
    module Naming

      # Returns the name of this content block as it will appear in paths.
      #
      # Examples:
      #   HtmlBlock -> html_blocks
      #   Thing -> things
      def path_name
        model_name.element.pluralize
      end
    end
  end
end
