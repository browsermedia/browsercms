class Portlet < ActiveRecord::Base

  validates_presence_of :name

  #These are here simply to temporarily hold these values
  #Makes it easy to pass them through the process of selecting a portlet type
  attr_accessor :connect_to_page_id, :connect_to_container
  
  def self.inherited(subclass)
    super if defined? super
  ensure
    ( @subclasses ||= [] ).push(subclass).uniq!
    subclass.has_dynamic_attributes
    subclass.acts_as_content_block(:versioned => false, :publishable => false)    
  end

  # In Rails, Classeses aren't loaded until you ask for them
  # This method will load all portlets that are defined
  # in a app/portlets directory on the load path
  def self.load_portlets
    ActiveSupport::Dependencies.load_paths.each do |d| 
      if d =~ /app\/portlets/
        Dir["#{d}/*_portlet.rb"].each{|p| require_dependency(p) }
      end
    end
  end

  def self.has_edit_link?
    false
  end
  
  def self.types
    load_portlets
    @subclasses || []
  end

  def self.get_subclass(type)
    raise "Unknown Portlet Type" unless types.map(&:name).include?(type)
    type.constantize 
  end

  def self.content_block_type
    "portlet"
  end 
  
  # For column in list
  def portlet_type_name
    type.titleize
  end

  def self.form
    "portlets/#{name.tableize.sub('_portlets','')}/form"
  end
  
  def self.partial
    "portlets/#{name.tableize.sub('_portlets','')}/render"
  end

  def type_name
    type.to_s.titleize
  end

  def self.columns_for_index
    [ {:label => "Name", :method => :name, :order => "name" },
      {:label => "Type", :method => :type_name, :order => "type" } ]
  end
  
  def instance_name
    "#{self.class.name.demodulize.underscore}_#{id}"
  end
  
  # Subclasses should override this method if you want different behavior
  def renderer(portlet)
    lambda do
      render :partial => portlet.class.partial, :locals => {:portlet => portlet}
    end
  end
  
end