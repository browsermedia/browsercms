require 'cms/extensions'
require 'cms/init'
require 'cms/routes'
require 'cms/caching'

#Load libraries that are included with CMS
require 'acts_as_list'
ActiveRecord::Base.send(:include, ActsAsList)

require 'cms/acts'
require 'cms/authentication'
require 'cms/behaviors'
require 'cms/domain_support'
require 'cms/content_rendering_support'
require 'command_line'