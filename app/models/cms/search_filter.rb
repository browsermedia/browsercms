module Cms
  # Captures values for the search form.
  class SearchFilter
    include ::ActiveModel::Model

    attr_accessor :model_class, :term

    def self.build(params_hash, model_class)
      model = self.new(params_hash)
      model.model_class = model_class
      model
    end

    def path
      model_class
    end
  end
end