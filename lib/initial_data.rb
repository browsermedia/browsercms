class InitialData
  
  extend Cms::DataLoader
  
  #Fixture-like way of creating initial data, except that it actually calls the real model methods
  #This way things like acts_as_list and versioning get setup properly for these records
  #The syntax is that you call create_whatever(:something, ...), where whatever is the model name,
  #something is the identifier you give this record, and the ... is the hash of options to pass
  #to the model constructor.  By calling the create_ method, you can then refer to the record later
  #in the same way you would with fixtures, by saying whatevers(:something)
  def self.load_demo
    eval open("#{Rails.root}/db/demo/data.rb"){|f| f.read}
    
    Dir["#{Rails.root}/db/demo/page_partials/*.erb"].map do |f|
      name, format, handler = File.basename(f).split('.')
      create_page_partial(name.to_sym, 
        :name => name, :format => format, :handler => handler,
        :body => open(f){|f| f.read})
    end
    
    Dir["#{Rails.root}/db/demo/page_templates/*.erb"].map do |f|
      name, format, handler = File.basename(f).split('.')
      create_page_template(name.to_sym, 
        :name => name, :format => format, :handler => handler,
        :body => open(f){|f| f.read})
    end
    
  end
  
end