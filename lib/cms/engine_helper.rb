module Cms
  module EngineHelper

    def main_app_model?
      engine_name == "main_app"
    end

    def engine_exists?
      !main_app_model?
    end

    def engine_name
      name = EngineHelper.module_name(target_class)
      return "main_app" unless name

      begin
        engine = "#{name}::Engine".constantize
      rescue NameError
        # This means there is no Engine for this model, so its from the main Rails App.
        return "main_app"
      end
      engine.engine_name
    end

    def path_elements
      path = []
      path << "cms" if main_app_model?
      path << path_subject
    end

    # Subclasses can override this as necessary
    def target_class
      return self.class unless self.instance_of?(Class)
      self
    end

    # Subclasses can override this as necessary
    def path_subject
      self
    end

    # Add this module if its not already.
    def self.decorate(instance)
      instance.extend EngineHelper unless instance.respond_to?(:engine_name)
    end

    # Finds the top level module for a given class.
    # Cms::Thing -> Cms
    # Thing -> nil
    # Whatever::Thing -> Whatever
    #
    # @param [Class] klass
    def self.module_name(klass)
      names = klass.name.split("::")
      return names.first if names.size > 1
      nil
    end
  end
end