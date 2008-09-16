#Once we gemify CMS, this stuff should go in rails/init.rb
require 'cms/extensions'

logger = Rails.logger

#Load Erubis, if we can
begin
  require 'erubis/helpers/rails_helper'
rescue Exception
  logger.warn("~~ Could not load Erubis.  'gem install erubis' for faster template rendering")
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

#Write out the page templates to the file system
if ActiveRecord::Base.connection.tables.include?("page_templates")
  tmp_view_path = "#{Rails.root}/tmp/views"
  logger.info("~~ Writing page templates to #{tmp_view_path}")
  ActionController::Base.append_view_path tmp_view_path
  PageTemplate.all.each{|pt| pt.create_layout_file }
end

module Cms
  def self.load_tasks
    load "#{File.dirname(__FILE__)}/tasks/cms.rake"
  end
end