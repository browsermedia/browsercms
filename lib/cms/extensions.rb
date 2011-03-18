Dir["#{File.join(File.dirname(__FILE__), "extensions")}/**/*.rb"].each do |f| 
  Rails.logger.info "~~ Loading extensions from #{f}" if Rails.logger
  require f
end
