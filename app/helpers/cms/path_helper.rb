module Cms

  # @todo All methods really need to be renamed to match conventions for Engines.
    # In CMS::Engine, shouldn't have cms_ in method name.
    # From app, should be cms.xyz_path
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
        cms.portlet_path(connectable)
      else
        connectable
      end
    end

    # @todo Really needs to be renamed to match conventions for Engines.
    # In CMS::Engine, should be edit_connectable_path
    # From app, should be cms.edit_connectable_path
    def edit_cms_connectable_path(connectable, options={})
      if Portlet === connectable
        edit_portlet_path(connectable, options)
      else
        polymorphic_path([:edit, connectable], options)
      end
    end
    
    private
      # Returns the name of the collection that this resource belongs to
      # the resource can be a ContentType, ActiveRecord::Base instance
      # or just a string or symbol
      def resource_collection_name(resource)
        if resource.respond_to?(:resource_collection_name)
          return resource.resource_collection_name
        end
        collection_name = case resource
          when ContentType then resource.model_class_form_name
          when ActiveRecord::Base then resource.class.model_name.demodulize
          else resource.to_s
        end
      end
        
  end
end
