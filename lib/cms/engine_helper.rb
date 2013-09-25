module Cms

  class EngineAwarePathBuilder


    attr_reader :path_subject

    def initialize(model_class_or_content_type_or_model)
      normalize_subject_class(model_class_or_content_type_or_model)
    end

    def subject_class
      if path_subject.instance_of?(Class)
        path_subject
      else
        path_subject.class
      end
    end

    def build_preview(view)
      path = []
      path << engine_name
      path << path_subject
      path
    end

    def build(view)
      path = []
      path << engine(view)
      path << path_subject
      path

    end

    def main_app_model?
      engine_name == "main_app"
    end

    # Determine which 'Engine' this model is from based on the class
    def engine_name
      model_class = subject_class.model_name
      name = EngineAware.module_name(model_class)
      return "main_app" unless name

      begin
        engine = "#{name}::Engine".constantize
      rescue NameError
        # This means there is no Engine for this model, so its from the main Rails App.
        return "main_app"
      end
      engine.engine_name
    end


    def engine_class
      if main_app_model?
        Rails.application
      else
        guess_engine_class(subject_class)
      end
    end

    private

    # Will raise NameError if klass::Engine doesn't exist.
    def guess_engine_class(klass)
      name = EngineAware.module_name(klass)
      "#{name}::Engine".constantize
    end

    # Allows ContentType, Class, or model to be passed.
    def normalize_subject_class(model_class_or_content_type_or_model)
      if model_class_or_content_type_or_model.respond_to? :model_class # i.e. ContentType
        @path_subject = model_class_or_content_type_or_model.model_class
      else # Class or Model
        @path_subject = model_class_or_content_type_or_model
      end
    end

    # Loads the actual engine (which contains the RouteSet.)
    # See http://api.rubyonrails.org/classes/ActionDispatch/Routing/PolymorphicRoutes.html
    def engine(view)
      view.send(engine_name)
    end


  end

  module EngineAware

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