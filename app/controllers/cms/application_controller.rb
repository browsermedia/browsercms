module Cms
  class ApplicationController < ::ApplicationController
    include Cms::AdminController
  end
end