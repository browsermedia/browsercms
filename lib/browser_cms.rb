require 'will_paginate'
require 'cms/extensions'
require 'cms/routes'

module Cms
  VERSION = "3.0.0"
end

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

#Include CMS Behaviors
ActiveRecord::Base.extend Cms::Acts::ContentObject
require 'cms/behaviors'