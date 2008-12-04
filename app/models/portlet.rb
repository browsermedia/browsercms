class Portlet < ActiveRecord::Base

  has_flex_attributes
  acts_as_content_block :versioned => false, :publishable => false
  validates_presence_of :name

  attr_accessor :request, :response, :params, :session
  
  def self.inherited(subclass)
    super if defined? super
  ensure
    ( @subclasses ||= [] ).push(subclass).uniq!
  end

  # In Rails, Classeses aren't loaded until you ask for them
  # This method will load all portlets that are defined
  # in a app/portlets directory on the load path
  def self.load_portlets
    Dependencies.load_paths.each do |d| 
      if d =~ /app\/portlets/
        Dir["#{d}/*_portlet.rb"].each{|p| require_dependency(p) }
      end
    end
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

  def form
    "cms/#{self.class.name.tableize}/form"
  end
  
  def partial
    "cms/#{self.class.name.tableize}/render"
  end

  def self.columns_for_index
    [{:label => "Type", :method => "portlet_type_name"}]
  end
end