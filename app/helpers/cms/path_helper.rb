module Cms
  module PathHelper
    def cms_index_path_for(resource, options={})
      send("#{resource_collection_name(resource).underscore.pluralize.gsub('/','_')}_path", options)
    end
    
    def cms_index_url_for(resource, options={})
      send("#{resource_collection_name(resource).underscore.pluralize.gsub('/','_')}_url", options)
    end
    
    def cms_new_path_for(resource, options={})
      send("new_#{resource_collection_name(resource).underscore.gsub('/','_')}_path", options)
    end
    
    def cms_new_url_for(resource, options={})
      send("new_#{resource_collection_name(resource).underscore.gsub('/','_')}_url", options)
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
        polymorphic_path([:edit, connectable], options)        
      end
    end
    
    private
      # Returns the name of the collection that this resouce belongs to
      # the resource can be a ContentType, ActiveRecord::Base instance
      # or just a string or symbol
      def resource_collection_name(resource)
        collection_name = case resource
          when ContentType then "cms_#{resource.name.underscore}"
          when ActiveRecord::Base then resource.class.name.underscore.gsub('/','_')
          else resource.to_s
        end
      end
        
  end
end
