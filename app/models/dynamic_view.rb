class DynamicView < ActiveRecord::Base
  
  after_save :write_file_to_disk
  after_destroy :remove_file_from_disk

  named_scope :with_file_name, lambda{|file_name|
    conditions = {:name => nil, :format => nil, :handler => nil}
    if file_name && (parts = file_name.split(".")).size == 3
      conditions[:name] = parts[0]
      conditions[:format] = parts[1]
      conditions[:handler] = parts[2]
    end
    {:conditions => conditions}
  }

  def self.inherited(subclass)
    super if defined? super
  ensure
    subclass.class_eval do
      flush_cache_on_change
      is_publishable
      uses_soft_delete
      is_userstamped
      is_versioned :version_foreign_key => "dynamic_view_id"

      before_validation :set_publish_on_save

      validates_presence_of :name, :format, :handler
      validates_uniqueness_of :name, :scope => [:format, :handler],
        :message => "Must have a unique combination of name, format and handler"
                  
    end 
  end
  
  def self.new_with_defaults(options={})
    new({:format => "html", :handler => "erb", :body => default_body}.merge(options))    
  end
  
  def self.find_by_file_name(file_name)
    with_file_name(file_name).first
  end
  
  def self.base_path
    File.join(Rails.root, "tmp", "views")
  end
  
  def file_name
    "#{name}.#{format}.#{handler}"
  end
  
  def display_name
    self.class.display_name(file_name)
  end  
  
  def write_file_to_disk
    if respond_to?(:file_path) && !file_path.blank?
      FileUtils.mkpath(File.dirname(file_path))
      open(file_path, 'w'){|f| f << body}
    end
  end
  
  def self.write_all_to_disk!
    all(:conditions => {:deleted => false}).each{|v| v.write_file_to_disk }
  end
  
  def remove_file_from_disk
    if respond_to?(:file_path) && File.exists?(file_path)
      File.delete(file_path)
    end
  end
  
  def self.default_body
    ""
  end
  
  def set_publish_on_save
    self.publish_on_save = true
  end
  
end
