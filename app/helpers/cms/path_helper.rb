module Cms
  module PathHelper
    def cms_index_path_for(resource, options={})
      send("cms_#{resource_collection_name(resource).pluralize}_path", options)
    end
    
    def cms_index_url_for(resource, options={})
      send("cms_#{resource_collection_name(resource).pluralize}_url", options)
    end
    
    def cms_new_path_for(resource, options={})
      send("new_cms_#{resource_collection_name(resource)}_path", options)
    end
    
    def cms_new_url_for(resource, options={})
      send("new_cms_#{resource_collection_name(resource)}_url", options)
    end
    
    #This method has several valid forms.  The most simple is to pass a string, to which the cms namespace will be added.
    #If you pass a symbol, this method will assume that is the controller.
    #If you pass an object like an Active Record model, then it will construct the url for that model.
    #If the last argument is a Hash, it will append those values as querystring parameters
    #If the action is :create_or_update, this will generate the proper url based on the status of the model.
    #For example, if you call cms_path(@block, :create_or_update), if the block is a new record, it will return '/cms/blocks/create',
    #but if the record is not a new record, if will return '/cms/blocks/update/1'
    #
    # Examples:
    # cms_path(:user) -> /cms/user
    #
    #
    #
    def cms_path(*args)    
      paths = ["", "cms"]
      params = Hash === args.last ? args.pop : {}

      first = args.delete_at(0)
      if [String, Symbol, Hash, Array, Numeric, Date, Time].detect{|e| e === first}
        paths << first.to_s.sub(/^\//,'')
      else
        if first.class.connectable? && ContentType.count(:conditions => ["name in (?)", [first.class.name, first.class.base_class.name]]) > 0
          paths << 'blocks'
          paths << first.content_block_type
        else
          paths << first.class.to_s.pluralize.underscore
        end
        action = (args.delete_at(0) || "show")
        if action.to_sym == :create_or_update
          if first.new_record?
            paths << :create
          else
            paths << :update
            paths << first.to_param
          end
        else
          paths << action
          paths << first.to_param
        end
      end

      paths += args.map(&:to_param)

      path = paths.join("/")    
      unless params.empty? 
        path << "?"
        path << params.to_a.sort_by {|e| e.first.to_s}.map {|k,v| "#{k}=#{CGI::escape(v.to_param.to_s)}"}.join("&")
      end
      path
    end  

    def cms_url(*args)
      "#{request.protocol}#{request.host_with_port}#{cms_path(*args)}"
    end

    private
      # Returns the name of the collection that this resouce belongs to
      # the resource can be a ContentType, ActiveRecord::Base instance
      # or just a string or symbol
      def resource_collection_name(resource)
        collection_name = case resource
          when ContentType: resource.name.underscore
          when ActiveRecord::Base: resource.class.name.underscore
          else resource.to_s
        end
      end
        
  end
end
