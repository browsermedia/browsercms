# Each concern should be automatically added to each ActiveRecord class using extend.
module Cms::Concerns; end

Dir["#{File.dirname(__FILE__)}/concerns/*.rb"].each do |b|
  require File.join("cms", "concerns", File.basename(b, ".rb"))
  ActiveRecord::Base.extend "Cms::Concerns::#{File.basename(b, ".rb").camelize}".constantize
end