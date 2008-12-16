module Cms
  module DataLoader
    def method_missing(method_name, *args)
      if md = method_name.to_s.match(/^create_(.+)$/)
        begin
          #Make sure this is an active record class
          super unless md[1].classify.constantize.ancestors.include?(ActiveRecord::Base)
        rescue NameError => e
          super
        end
        self.create(md[1], args[0], args[1] || {})
      elsif @data && @data.has_key?(method_name)
        record = @data[method_name][args.first]
        record ? record.class.find(record.id) : nil
      else
        super
      end
    end
    def create(model_name, record_name, data={})
      puts "-- create_#{model_name}(:#{record_name})"
      @data ||= {}
      @data[model_name.pluralize.to_sym] ||= {}
      model = model_name.classify.constantize.new(data)
      model.save!
      @data[model_name.pluralize.to_sym][record_name] = model
    end
  end
end