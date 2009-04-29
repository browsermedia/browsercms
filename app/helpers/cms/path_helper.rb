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
    
    def cms_connectable_path(connectable, options={})
      if Portlet === connectable
        cms_portlet_path(connectable)
      else
        [:cms, connectable]
      end
    end
    
    def edit_cms_connectable_path(connectable, options={})
      if Portlet === connectable
        edit_cms_portlet_path(connectable, options)
      else
        polymorphic_path([:edit, :cms, connectable], options)        
      end
    end
    
    private
      # Returns the name of the collection that this resouce belongs to
      # the resource can be a ContentType, ActiveRecord::Base instance
      # or just a string or symbol
      def resource_collection_name(resource)
        collection_name = case resource
          when ContentType then resource.name.underscore
          when ActiveRecord::Base then resource.class.name.underscore
          else resource.to_s
        end
      end
        
  end
end
