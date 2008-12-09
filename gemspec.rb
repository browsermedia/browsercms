SPEC = Gem::Specification.new do |spec| 
  spec.name = "browser_cms" 
  spec.rubyforge_project = spec.name
  spec.version = "3.0.0" 
  spec.summary = "A Content Management System for Rails" 
  spec.author = "Browsermedia" 
  spec.email = "admin@browsercms.com" 
  spec.homepage = "http://www.browsercms.com" 
  spec.files = Dir["rails/*.rb"]
  spec.files += Dir["app/**/*"]
  spec.files += Dir["db/migrate/[0-9]*_*.rb"]
  spec.files += Dir["lib/**/*"]
  spec.files += Dir["rails_generators/**/*"]
  spec.files += Dir["public/stylesheets/cms/**/*"]
  spec.files += Dir["public/javascripts/jquery*"]
  spec.files += Dir["public/javascripts/cms/**/*"]
  spec.files += Dir["public/fckeditor/**/*"]
  spec.files += Dir["public/site/**/*"]  
  spec.files += Dir["public/images/cms/**/*"]
  spec.has_rdoc = true
  spec.extra_rdoc_files = ["README"]
  spec.require_path "lib"
end