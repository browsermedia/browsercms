# For scenarios that need to behave under a 'production' environment
# where page caching is on, we need to clean up and make sure we reset and clean up page cache after each scenario.
Around('@page-caching') do |scenario, block|
  ActionController::Base.perform_caching = true
  begin
    block.call
  ensure
    Cms::Cache.flush
    ActionController::Base.perform_caching = false
  end
end