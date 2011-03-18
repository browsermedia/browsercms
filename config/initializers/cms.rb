# This should no longer be necessary to test
# browserCMS as both a gem and local project.
#
#require 'browsercms'
#
## Initializes the CMS as an App, rather than as gem.
## Applies only for root rails app, or when running tests.
#if defined?(Browsercms::Application)
#  Cms::Engine.add_cms_routes_method
#  Cms::Engine.add_cms_load_paths
#  Cms.add_to_rails_paths(Cms.root)
#end