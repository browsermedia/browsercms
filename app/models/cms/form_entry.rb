module Cms
  class FormEntry < ActiveRecord::Base

    store :data_columns
    belongs_to :form, class_name: 'Cms::Form'

    after_initialize :add_field_accessors

    def permitted_params
      form.field_names
    end

    # Returns a copy of the persisted object. This is required so that existing records fetched from the db can
    # have validation during update operations.
    #
    # @return [Cms::FormEntry] A copy of this record with validations enabled on it.
    def enable_validations
      entry = FormEntry.for(form)
      entry.attributes = self.attributes
      entry.instance_variable_set(:@new_record, false)
      entry
    end

    class << self

      def search(term)
        where("data_columns like ?", "%#{term}%")
      end
      
      # Create an Entry for a specific Form. It will have validation and accessors based on the fields of the form.
      #
      # @param [Cms::Form] form
      def for(form)
        entry = FormEntry.ish(form: form) {
          form.field_names.each do |field_name|
            if form.required?(field_name)
              validates field_name, presence: true
            end
          end
        }
        entry
      end

      # Create an instance of a FormEntry with the given methods.
      def ish(*args, &block)
        dup(&block).new(*args)
      end

      # Creates a faux class with singleton methods. Solves this problem:
      #   https://github.com/rails/rails/issues/5449
      def dup(&block)
        super.tap do |dup|
          def dup.name()
            FormEntry.name
          end

          dup.class_eval(&block) if block
        end
      end
    end
    private

    # Add a single field accessor to the current instance of the object. (I.e. not shared with others)
    def add_store_accessor(field_name)
      singleton_class.class_eval { store_accessor :data_columns, field_name }
    end

    def add_field_accessors
      return unless form
      form.field_names.each do |field_name|
        add_store_accessor(field_name)
      end
    end
  end
end