require 'cms/extensions'

#Load Erubis, if we can
begin
  require 'erubis/helpers/rails_helper'
rescue Exception
  Rails.logger.warn("~~ Could not load Erubis.  'gem install erubis' for faster template rendering")
end

#Load libraries that are included with CMS
require 'acts_as_list'
ActiveRecord::Base.send(:include, ActsAsList)

require 'flex_attributes'
ActiveRecord::Base.send(:include, FlexAttributes)

require 'version_fu'
ActiveRecord::Base.send(:include, VersionFu)

#Include CMS extensions
ActiveRecord::Base.send(:include, Cms::Acts::ContentObject)