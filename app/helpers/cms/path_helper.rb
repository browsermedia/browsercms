module Cms
  module PathHelper
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
        path << params.to_a.map{|k,v| "#{k}=#{CGI::escape(v.to_param.to_s)}"}.join("&")
      end
      path
    end  

    def cms_url(*args)
      "#{request.protocol}#{request.host_with_port}#{cms_path(*args)}"
    end
  end
end