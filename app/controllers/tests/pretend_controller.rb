# This class exists to provide a test for including page behavior in controllers.
# I didn't know of a way to add functional tests for controllers/routes that aren't in
# the apps directory.
#
# This should be moved to the test directory if possible.
class Tests::PretendController < ApplicationController
  include Cms::Acts::ContentPage

  # Needed for the error/access denied pages to work.
  helper Cms::PageHelper
  helper Cms::MenuHelper
  helper Cms::ApplicationHelper
  
  place_in_section "/members", :except=>[:open]

  def restricted
    render :text =>"You can see this restricted page."
  end

  def open
    render :text =>"You can see this public page."
   
  end

end
