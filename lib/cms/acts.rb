# Requires all files in the Acts As directory
#
# This adds the ContentBlock behavior to all Active Record objects.
Dir["#{File.dirname(__FILE__)}/acts/*.rb"].each do |b| 
  require File.join("cms", "acts", File.basename(b, ".rb"))
end
ActiveRecord::Base.send(:include, Cms::Acts::ContentBlock)
