module Cms::Behaviors; end
Dir["#{File.dirname(__FILE__)}/behaviors/*.rb"].each do |b| 
  require File.join("cms", "behaviors", File.basename(b, ".rb"))
  ActiveRecord::Base.send(:include, "Cms::Behaviors::#{File.basename(b, ".rb").camelize}".constantize)
end
