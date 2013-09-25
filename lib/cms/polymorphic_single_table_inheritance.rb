module Cms
  # Allows STI classes to be handled by a single resource controller
  # i.e. LoginPortlet can be handled by the Cms::PortletController as a resource.
  #
  #
  # This is a simpler version of this solution: https://gist.github.com/sj26/5843855
  module PolymorphicSingleTableInheritance

    # Override model_name to return base_class Name.
    def model_name
      if self == base_class
        super
      else
        base_class.model_name
      end
    end

  end
end