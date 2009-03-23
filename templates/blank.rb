run "rm public/index.html"
gem "browser_cms"
route "map.routes_for_browser_cms"
generate(:browser_cms)
rake("db:create")
rake("db:migrate")