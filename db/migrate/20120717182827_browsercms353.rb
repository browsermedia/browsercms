require 'cms/upgrades/v3_5_0'

class Browsercms353 < ActiveRecord::Migration
  def change
    namespace_templates
    
    # Some older projects may have AbstractFileBlock rather than File/ImageBlock connectors
    v3_5_0_update_connector_namespaces("Cms", "AbstractFileBlock")
    
  end
  
  private
  
  def namespace_templates
    ["PageTemplate", "PagePartial"].each do |view|
      Cms::DynamicView.update_all("type = 'Cms::#{view}'", "type = '#{view}'" )
    end
  end
end
