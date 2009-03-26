class DynamicView < ActiveRecord::Base

  def self.inherited(subclass)
    super if defined? super
  ensure
    subclass.class_eval do
      flush_cache_on_change
      uses_soft_delete
      is_userstamped
      is_versioned :version_foreign_key => "dynamic_view_id"

      validates_presence_of :name, :format, :handler
      
      after_save :write_file_to_disk
      
    end
    
  end
  
  def self.new_with_defaults(options={})
    new({:format => "html", :handler => "erb", :body => default_body}.merge(options))    
  end
  
  def self.base_path
    File.join(Rails.root, "tmp", "views")    
  end
  
  def file_name
    "#{name}.#{format}.#{handler}"
  end
  
  def file_path
    raise "Subclasses must define where the file should be saved"
  end
  
  def write_file_to_disk
    FileUtils.mkpath(File.dirname(file_path))
    open(file_path, 'w'){|f| f << body}
  end
  
  def self.write_all_to_disk!
    all.each{|v| v.write_file_to_disk }
  end
  
  def self.default_body
    ""
  end
  
end
