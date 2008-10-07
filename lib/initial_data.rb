class InitialData
  
  #Fixture-like way of creating initial data, except that it actually calls the real model methods
  #This was things like acts_as_list and versioning get setup properly for these records
  #The syntax is that you call create_whatever(:something, ...), where whatever is the model name,
  #something is the identifier you give this record, and the ... is the hash of options to pass
  #to the model constructor.  By calling the create_ method, you can then refer to the record later
  #in the same way you would with fixtures, by saying whatevers(:something)
  def self.load_data
    t0 = Time.now
    puts "== Initial Data: creating ====================================================="
    eval open("#{Rails.root}/db/initial_data.rb"){|f| f.read}
    puts "== Initial Data: created (%0.4fs) ============================================\n" % (Time.now - t0)
  end
  
  def self.method_missing(method_name, *args)
    if method_name.to_s.match(/\Acreate_(.+)\Z/)
      self.create($1, args[0], args[1] || {})
    elsif @data && @data.has_key?(method_name)
      record = @data[method_name][args.first]
      record ? record.class.find(record.id) : nil
    else
      super
    end
  end
  def self.create(model_name, record_name, data={})
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