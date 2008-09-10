#Once we gemify CMS, this stuff should go in rails/init.rb
require 'cms/extensions'

logger = Rails.logger

begin
  require 'erubis/helpers/rails_helper'
rescue Exception
  logger.warn("~~ Could not load Erubis.  'gem install erubis' for faster template rendering")
end

ActiveRecord::Base.send(:include, Cms::Acts::ContentObject)

if ActiveRecord::Base.connection.tables.include?("page_templates")
  tmp_view_path = "#{Rails.root}/tmp/views"
  logger.info("~~ Writing page templates to #{tmp_view_path}")
  ActionController::Base.append_view_path tmp_view_path
  PageTemplate.all.each{|pt| pt.create_layout_file }
end