class Portlet < ActiveRecord::Base

  validates_presence_of :name

  #These are here simply to temporarily hold these values
  #Makes it easy to pass them through the process of selecting a portlet type
  attr_accessor :connect_to_page_id, :connect_to_container
  
  def self.inherited(subclass)
    super if defined? super
  ensure
    subclass.class_eval do
      
      has_dynamic_attributes
      
      acts_as_content_block(
        :versioned => false, 
        :publishable => false,
        :renderable => {:instance_variable_name_for_view => "@portlet"})
      
      def self.helper_path
        "app/portlets/helpers/#{name.underscore}_helper.rb"
      end

      def self.helper_class
        "#{name}Helper".constantize
      end      
    end      
  end

  def self.has_edit_link?
    false
  end
  
  def self.types
    @types ||= ActiveSupport::Dependencies.load_paths.map do |d| 
      if d =~ /app\/portlets/
        Dir["#{d}/*_portlet.rb"].map do |p| 
          File.basename(p, ".rb").classify
        end
      end
    end.flatten.compact.uniq.sort
  end

  def self.get_subclass(type)
    raise "Unknown Portlet Type" unless types.map(&:name).include?(type)
    type.constantize 
  end

  def self.content_block_type
    "portlet"
  end 
  
  def self.content_block_type_for_list
    "portlet"
  end
  
  # For column in list
  def portlet_type_name
    type.titleize
  end

  def self.form
    "portlets/#{name.tableize.sub('_portlets','')}/form"
  end
  
  def self.default_template
    template_file = ActionController::Base.view_paths.map do |vp| 
      path = vp.to_s.first == "/" ? vp.to_s : Rails.root.join(vp.to_s)
      Dir[File.join(path, default_template_path) + '.*']
    end.flatten.first
    template_file ? open(template_file){|f| f.read } : ""
  end
  
  def self.set_default_template_path(s)
    @default_template_path = s
  end
  
  def self.default_template_path
    @default_template_path ||= "portlets/#{name.tableize.sub('_portlets','')}/render"
  end

  def inline_options
    {:inline => self.template}
  end

  def type_name
    type.to_s.titleize
  end

  def self.columns_for_index
    [ {:label => "Name", :method => :name, :order => "name" },
      {:label => "Type", :method => :type_name, :order => "type" },
      {:label => "Updated On", :method => :updated_on_string, :order => "updated_at"} ]
  end
  
  def instance_name
    "#{self.class.name.demodulize.underscore}_#{id}"
  end
  
end