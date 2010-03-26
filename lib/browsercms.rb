require 'cms/extensions'
require 'cms/init'
require 'cms/routes'
require 'cms/caching'

#Load libraries that are included with CMS
require 'acts_as_list'
ActiveRecord::Base.send(:include, ActsAsList)

#Include CMS Behaviors
ActiveRecord::Base.send(:include, Cms::Acts::ContentBlock)
require 'cms/behaviors'

require 'namespacing_support'
ActiveSupport::Inflector::Inflections.send(:extend, NamespacingSupport::Inflector)
String.send(:include, NamespacingSupport::Inflections )
