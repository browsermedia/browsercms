# Require all files in the cms/authentication directory
Dir["#{File.dirname(__FILE__)}/authentication/*.rb"].each do |b|
  require File.join("cms", "authentication", File.basename(b, ".rb"))
end