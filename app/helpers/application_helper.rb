# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def render_connector(connector)
    if logged_in? && @mode == "edit"
      render :partial => 'cms/pages/edit_connector', :locals => {:connector => connector}
    else
      render_content_block(connector.content_block)
    end
  end
  
  def render_content_block(block)
    # block.request = request if block.respond_to?(:request=)
    # block.response = request if block.respond_to?(:response=)
    # block.params = request if block.respond_to?(:params=)    
    # block.session = request if block.respond_to?(:session=)    
    block.render
  end
  
  def container(name)
    content = instance_variable_get("@content_for_#{name}")
    if logged_in? && @mode == "edit"
      render :partial => 'cms/pages/edit_container', :locals => {:name => name, :content => content}
    else
      content
    end
  end
  
  def action_icon(name, options={})
    image_tag "cms/icons/actions/#{name}.png", {:alt => name.to_s.titleize}.merge(options)
  end

  def status_icon(status, options={})
    image_tag "cms/icons/status/#{status.underscore}.gif", {:alt => status.titleize}.merge(options)
  end
  
  def cms_toolbar
    render :partial => 'layouts/cms_toolbar'    
  end
  
  def eval_haml(haml, locals={})
    obj = Object.new
    Haml::Engine.new(haml).def_method(*([obj, :render] + locals.keys))
    obj.render(locals)
  end
    
  #This method has several valid forms.  The most simple is to pass a string, to which the cms namespace will be added.
  #If you pass a symbol, this method will assume that is the controller.
  #If you pass an object like an Active Record model, then it will construct the url for that model.
  #If the last argument is a Hash, it will append those values as querystring parameters
  def cms_path(*args)    
    paths = ["", "cms"]
    params = Hash === args.last ? args.pop : {}
    
    first = args.delete_at(0)
    if [String, Symbol, Hash, Array, Numeric, Date, Time].detect{|e| e === first}
      paths << first.to_s.sub(/^\//,'')
    else
      paths << first.class.to_s.pluralize.underscore
      paths << (args.delete_at(0) || "show")
      paths << first.to_param
    end
    
    paths += args.map(&:to_param)
  
    path = paths.join("/")    
    unless params.empty? 
      path << "?"
      path << params.to_a.map{|k,v| "#{k}=#{CGI::escape(v.to_s)}"}.join("&")
    end
    path
  end  
    
end
