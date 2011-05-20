module Cms
  module DataLoader

    mattr_accessor :silent_mode

    def method_missing(method_name, *args)
      if md = method_name.to_s.match(/^create_(.+)$/)
        # We search the CMS namespace first.
        # for things like DynamicPortlets "Cms::DynamicPortlet".constantize returns "DynamicPortlet"
        model_name = "Cms/#{md[1]}".classify.constantize.name        
        begin
          #Make sure this is an active record class
          super unless model_name.classify.constantize.ancestors.include?(ActiveRecord::Base)
        rescue NameError => e
          super
        end
        self.create(model_name, args[0], args[1] || {})
      elsif @data && @data.has_key?(method_name)
        record = @data[method_name][args.first]
        record ? record.class.find(record.id) : nil
      else
        super
      end
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