class PageRoute < ActiveRecord::Base
  belongs_to :page
  has_many :conditions, :class_name => "PageRouteCondition"
  has_many :requirements, :class_name => "PageRouteRequirement"
  
  validates_presence_of :pattern, :page_id
  validates_uniqueness_of :pattern

  after_save :reload_routes

  def reload_routes
    ActionController::Routing::Routes.load!
  end

  def add_condition(name, value)
    conditions.build(:name => name.to_s, :value => value.to_s)
  end  
  
  def add_requirement(name, value)
    requirements.build(:name => name.to_s, :value => value.to_s)
  end
  
  def conditions_map
    conditions.inject({}){|acc, e| acc[e.name.to_sym] = e.value.to_sym; acc}
  end
  
  def requirements_map
    requirements.inject({}){|acc, e| acc[e.name.to_sym] = Regexp.new(e.value); acc}
  end
  
  def route_name
    name ? name.to_slug.gsub('-','_') : nil
  end
  
  # This is used in defining the route in the ActionController::Routing
  def options_map
    m = {:controller => "cms/content", :action => "show_page_route"}
    
    m[:_page_route_id] = self.id.to_s
    
    m[:requirements] = requirements_map
    m[:conditions] = conditions_map
    
    m
  end
  
  # This is called by an instance of the content controller 
  # in the process of rendering a page.  This will eval the code
  # stored in this page route in the context of the controller.  
  # The main purpose of this method is to set instance variables 
  # that will be used by one or more portlets when the page is rendered.  
  # To set an instance variable, the code should contain something like:
  #    @news_article = NewsArticle.find(params[:id]))
  def execute(controller)
    controller.instance_eval(code) unless code.blank?
  end
  
end
