class Cms::MissingAssetController < ApplicationController
  def index
    logger.error("ASSET MISSING: #{request.request_uri}")
    render :text => "Not Found", :status => 404
  end
end