# Allows Rails routes to be matched to CMS pages, allowing arbitrary code that can be executed before the page is rendered.
#
# The primary goal of this is to provide human readable (and cachable) URLs for content_blocks. For example,
# a single 'Article' page can have a portlet that knows how to look up and display an Article by id. By default, this
# would look like this:
#   GET /article?id=120
#
# Unless the Article page is marked a 'cache enabled = false' this will cause problems. Plus that URL is ugly.
# With PageRoutes, you can have multiple URLs all map to the article page, like so:
#   GET /article/2010/12/30/article-1
#   GET /article/2011/1/18/article-2
# In both these cases, these URLs can be matched to a Rails Route which is linked to a page:
# GET /article/:year/:month/:day/:slug -> Articles Page
#
# Saving a new PageRoute will reload the Rails routes.
#
class Cms::PageRoute < ActiveRecord::Base


  belongs_to :page, :class_name => 'Cms::Page'
  has_many :conditions, :class_name => 'Cms::PageRouteCondition'
  has_many :requirements, :class_name => 'Cms::PageRouteRequirement'

  attr_accessible :name, :pattern, :code, :page_id, :page
  
  validates_presence_of :pattern, :page_id
  validates_uniqueness_of :pattern

  after_save :reload_routes


  # Determines if its safe to call any persistent methods on PageRoutes. This can be false if either the database doesn't exist,
  # or the page_routes table doesn't yet exist.
  #
  # @return [Boolean] Whether its safe to call any ActiveRecord persistent method or not.
  def self.can_be_loaded?
    database_exists? && table_exists?
  end

  # Force Rails to reload the routes. Allows modules to call this without concern that the Rails classes are going to change again.
  def self.reload_routes
    Rails.application.reload_routes!
  end

  def reload_routes
    Cms::PageRoute.reload_routes
  end

  def add_condition(name, value)
    conditions.build(:name => name.to_s, :value => value.to_s)
  end

  # @deprecated Use add_constraint instead (matches Rails 3 syntax)
  def add_requirement(name, value)
    requirements.build(:name => name.to_s, :value => value.to_s)
  end

  alias_method :add_constraint, :add_requirement

  # @deprecated Rails 3 no longer uses a 'conditions' element in its syntax for routing.
  def conditions_map
    conditions.inject({}) { |acc, e| acc[e.name.to_sym] = e.value.to_sym; acc }
  end


  def requirements_map
    requirements.inject({}) { |acc, e| acc[e.name.to_sym] = Regexp.new(e.value); acc }
  end

  def route_name
    name ? name.to_slug.gsub('-', '_') : nil
  end

  alias_method :as, :route_name

  def to
    "cms/content#show_page_route"
  end

  # @param [Symbol | Array] method A method name (like :get) or array of names (ie. [:get :post]) to constraint this route.
  def via=(method)
    if method.respond_to?(:each)
      method.each do |m|
        add_condition(:method, m)
      end
    else
      add_condition(:method, method)
    end
  end

  # Returns which methods this route can be via. Defaults to [:get, :post] if not specified.
  def via
    found = conditions.collect() { |condition|
      if condition.name.to_sym == :method;
        condition.value.to_sym
      end }
    methods = found.compact
    if methods.empty?
      methods << :get << :post
    end
    methods
  end

  # Builds a hash which can be passed to the :constraints value in a route, like:
  #
  # match 'some/:pattern', :constraints => page_route.constraints()
  def constraints
    requirements_map
  end

  # This is used in defining the route in the ActionController::Routing
  # Used in Rails 2 version of routing (No longer valid for rails 3)
  # @deprecated
  def options_map
    m = {:controller => "cms/content", :action => "show_page_route"}

    m[:_page_route_id] = self.id.to_s

    m[:requirements] = requirements_map
    m[:conditions] = conditions_map

    m
  end

  def page_route_id
    self.id.to_s
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
