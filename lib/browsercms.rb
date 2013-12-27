# Load all dependencies needed at boot time.
require 'rails'
require 'cms/configuration'
require 'cms/version'
require 'browsercms'

require 'bootstrap-sass'
require 'compass-rails'

# Gem name is different than file name
# Must be required FIRST, so that our assets paths appear before its do.
# This allows app/assets/ckeditor/config.js to set CMS specific defaults.
require 'ckeditor-rails'

# Explicitly require this, so that CMS projects do not need to add it to their Gemfile
# especially while upgrading
require 'jquery-rails'
require 'jquery-ui-rails'

require 'underscore-rails'
require 'will_paginate'
require 'will_paginate/active_record'
require 'actionpack/page_caching'
require 'panoramic'
require 'simple_form'
require 'devise'

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
require 'cms/content_page'
require 'cms/configuration/configurable_template'
require 'cms/domain_support'
require 'cms/authoring'
require 'cms/date_picker'
require 'cms/content_rendering_support'
require 'cms/mobile_aware'
require 'cms/attachments/configuration'
require 'cms/controllers/admin_controller'
require 'cms/default_accessible'
require 'cms/admin_tab'
require 'cms/publish_workflow'
require 'cms/content_filter'
require 'cms/polymorphic_single_table_inheritance'
require 'cms/form_builder/default_input'
require 'cms/form_builder/content_block_form_builder'
require 'cms/form_builder/workflow_buttons'

# This shouldn't be necessary, except for the need to get into the loadpath for testing.
require 'command_line'

#Include CMS Behaviors
ActiveRecord::Base.send(:include, Cms::Acts::ContentBlock)
require 'cms/behaviors'
require 'cms/concerns'


ActiveRecord::Base.send(:include, Cms::Acts::CmsUser)
require 'cms/responders/content_responder'

require "panoramic"
