module Cms
  module DataLoader
    def method_missing(method_name, *args)
      if method_name.to_s.match(/\Acreate_(.+)\Z/)
        self.create($1, args[0], args[1] || {})
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
      #Set the id of the record to be a consistent value, as fixtures in Rails do    
      model.id = record_name.to_s.hash.abs 
      model.save!
      @data[model_name.pluralize.to_sym][record_name] = model
    end
  end
end