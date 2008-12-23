require 'cms/extensions'
require 'cms/routes'

module Cms
  VERSION = "3.0.0"
  BUILD = "9"
end

#Load libraries that are included with CMS
require 'acts_as_list'
ActiveRecord::Base.send(:include, ActsAsList)

#Include CMS Behaviors
ActiveRecord::Base.send(:include, Cms::Acts::ContentBlock)
require 'cms/behaviors'