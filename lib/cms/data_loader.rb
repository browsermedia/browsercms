module Cms
  # A DSL for creating CMS content in seed data. Creating content in this manner will log the creation of the record
  # and store any created records in a hash.
  # To use, add the following to your seeds.rb.
  # require "cms/data_loader"
  #
  # @example Create a Page in the root section
  #   create_page(:hello, name: "Hello", path: "/hello", parent: sections(:root))
  #
  # @example Lookup a previously created page
  #   puts pages(:hello).name
  module DataLoader

    mattr_accessor :silent_mode

    def method_missing(method_name, *args)
      if md = method_name.to_s.match(/^create_(.+)$/)
        klass = model_class(md[1])
        self.create(klass.name, args[0], args[1] || {})
      elsif @data && @data.has_key?(method_name)
        record = @data[method_name][args.first]
        record ? record.class.find(record.id) : nil
      else
        super
      end
    end

    # We search the CMS namespace first.
    # for things like DynamicPortlets "Cms::DynamicPortlet".constantize returns "DynamicPortlet"
    def model_class(model_name)
      klass = begin
        "Cms/#{model_name}".classify.constantize
      rescue NameError => e
        model_name.classify.constantize
      end
      unless klass.method_defined?(:save!)
        raise "Can't create an instance of #{klass} because its not an ActiveRecord instance."
      end
      klass
    end


    def create(model_name, record_name, data={})
      puts "-- create_#{model_name}(:#{record_name})" unless Cms::DataLoader.silent_mode
      @data ||= {}
      model_storage_name = model_name.demodulize.underscore.pluralize.to_sym
      @data[model_storage_name] ||= {}
      model = model_name.classify.constantize.new(data)
      model.save!
      @data[model_storage_name][record_name] = model
    end
  end
end
extend Cms::DataLoader