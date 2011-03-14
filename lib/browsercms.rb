#puts "init browsercms.rb"

require 'cms/engine'
require 'cms/extensions'
require 'cms/routes'
require 'cms/caching'

#Load libraries that are included with CMS
require 'acts_as_list'
ActiveRecord::Base.send(:include, ActsAsList)

require 'cms/acts'
require 'cms/authentication'
require 'cms/behaviors'
require 'cms/domain_support'
require 'cms/date_picker'
require 'cms/content_rendering_support'

# This shouldn't be necessary, except for the need to get into the loadpath for testing.
require 'command_line'