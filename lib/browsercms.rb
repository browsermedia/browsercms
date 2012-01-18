require 'cms/extensions'
require 'cms/init'
require 'cms/routes'
require 'cms/caching'
require 'cms/addressable'
require 'cms/error_pages'

#Load libraries that are included with CMS
require 'acts_as_list'
ActiveRecord::Base.send(:include, ActsAsList)

#Include CMS Behaviors
ActiveRecord::Base.send(:include, Cms::Acts::ContentBlock)
require 'cms/behaviors'