ActionController::Routing::Routes.draw do |map|
  map.instance_eval(open("#{Rails.root}/rails/routes.rb"){|f| f.read})
end