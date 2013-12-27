module Cms
  module WorkflowButtons
    def publish_button(*args, &block)
      button_with_normalized_options(args, "Publish") do |options|
        options[:class] << "btn-primary right"
      end
    end

    def save_draft(*args, &block)
      button_with_normalized_options(args, "Save Draft")
    end

    def save(*args, &block)
      button_with_normalized_options(args, "Save") do |opts|
        opts[:class] << "btn-primary right"
      end
    end

    private

    def normalize_location(options)
      location = options.delete(:location)
      if location == :top
        options[:class] << 'btn-small'
      end
    end

    def button_with_normalized_options(args, label, &block)
      options = args.extract_options!.dup
      normalize_location(options)
      yield options if block_given?
      args << options
      args.unshift label
      button(:submit, *args, &block)
    end
  end
end
SimpleForm::FormBuilder.send :include, Cms::WorkflowButtons