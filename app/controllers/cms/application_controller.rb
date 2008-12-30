class Cms::ApplicationController < ApplicationController
  include Cms::Authentication::Controller
  include Cms::ErrorHandling

  helper :all # include all helpers, all the time

  helper Cms::ApplicationHelper
  include Cms::PathHelper
  helper Cms::PathHelper
  helper Cms::MenuHelper
  
end