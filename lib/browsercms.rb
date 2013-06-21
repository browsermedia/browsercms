require 'cms/engine'
require 'cms/extensions'
require 'cms/route_extensions'
require 'cms/caching'
require 'cms/error_pages'

#Load libraries that are included with CMS
require 'acts_as_list'
ActiveRecord::Base.send(:include, ActsAsList)

require 'cms/acts'
require 'cms/authentication'
require 'cms/domain_support'
require 'cms/authoring'
require 'cms/date_picker'
require 'cms/content_rendering_support'
require 'cms/mobile_aware'
require 'cms/attachments/configuration'
require 'cms/default_accessible'
require 'cms/admin_tab'
require 'cms/content_filter'

# This shouldn't be necessary, except for the need to get into the loadpath for testing.
require 'command_line'

#Include CMS Behaviors
ActiveRecord::Base.send(:include, Cms::Acts::ContentBlock)
require 'cms/behaviors'
require 'cms/concerns'


ActiveRecord::Base.send(:include, Cms::Acts::CmsUser)
require 'cms/responders/content_responder'

require "panoramic"