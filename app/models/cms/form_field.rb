module Cms
  class FormField < ActiveRecord::Base
    extend DefaultAccessible

    belongs_to :form
    acts_as_list scope: :form

    attr_accessor :edit_path, :delete_path

    # Name is assigned when the Field is created, and should not be changed afterwords.
    # Otherwise existing entries will not display their data correctly.
    #
    # FormField#name is used for input fields. I.e. <%= f.input field.name %>
    before_validation(on: :create) do
      self.name = label.parameterize.underscore.to_sym if label
    end

    validates :name, :uniqueness => {:scope => :form_id, message: "can only be used once per form."}

    def as_json(options={})
      super(:methods => [:edit_path, :delete_path])
    end


    # Return the form widget that should be used to render this field.
    #
    # @return [Symbol] A SimpleForm input mapping (i.e. :string, :text)
    def as
      case field_type
        when "text_field"
          :string
        when "text_area"
          :text
        else
          field_type.to_sym
      end
    end

    # Return options to be passed to a SimpleForm input.
    # @return [Hash]
    # @param [Hash] config
    # @option config [Boolean] :disabled If the field should be disabled.
    # @option config [FormEntry] :entry
    def options(config={})
      opts = {label: label}
      if field_type != "text_field"
        opts[:as] = self.as
      end
      if config[:disabled]
        opts[:disabled] = true
        opts[:readonly] = 'readonly'
      end
      opts[:required] = !!required
      opts[:hint] = instructions if instructions
      unless choices.blank?
        opts[:collection] = parse_choices
        opts[:prompt] = !self.required?
      end
      unless config[:entry] && config[:entry].send(name)
        opts[:input_html] =  {value: default_value}
      end
      opts
    end


    # Don't allow name to be set via UI.
    def self.permitted_params
      super - [:name]
    end

    private

    # Choices is a single text area where choices are divided by endlines.
    def parse_choices
      choices.split( /\r?\n/ )
    end
  end
end