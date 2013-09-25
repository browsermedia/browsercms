module Cms
  class Form < ActiveRecord::Base
    acts_as_content_block
    content_module :forms
    is_addressable path: '/forms', template: 'default'

    has_many :fields,  -> {order(:position)}, class_name: 'Cms::FormField'
    has_many :entries, class_name: 'Cms::FormEntry'

    validates_format_of :notification_email, :with => /@/, unless: lambda { |form| form.notification_email.blank? }

    # Copy any field related errors into the model :base so they get displayed at the top of the form.
    after_validation do
      unless errors[:fields].empty?
        fields.each do |field|
          field.errors.each do |attribute, error|
            errors[:base] << field.errors.full_message(attribute, error)
          end

        end
      end
    end

    def field(name)
      fields.select {|f| f.name == name}.first
    end

    def required?(name)
      field = field(name)
      field ? field.required? : false
    end

    def field_names
      fields.collect { |f| f.name }
    end

    def show_text?
      confirmation_behavior.to_sym == :show_text
    end

    # Provides a sample Entry for the form.
    # This allows us to use SimpleForm to layout out elements but ignore the input when the form submits.
    def new_entry
      Cms::Entry.new(form: self)
    end
  end
end
