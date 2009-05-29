# Remove the file on both *unix and Windows
run "rm public/index.html"
run "del public\\index.html"

gem "browsercms"
rake "db:create"
route "map.routes_for_browser_cms"
generate :browser_cms
environment 'SITE_DOMAIN="localhost:3000"', :env => "development"
environment 'SITE_DOMAIN="localhost:3000"', :env => "test"
environment 'SITE_DOMAIN="localhost:3000"', :env => "production"
environment 'config.action_view.cache_template_loading = false', :env => "production"
environment 'config.action_controller.page_cache_directory = RAILS_ROOT + "/public/cache/"', :env => "production"
generate :browser_cms_demo_site
rake "db:migrate"
