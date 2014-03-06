module Cms
  class ApplicationController < ::ApplicationController
    default_form_builder = Cms::FormBuilder::ContentBlockFormBuilder
    include Cms::AdminController

  end
end