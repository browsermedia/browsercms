# This class exists to provide a test for including page behavior in controllers.
# I didn't know of a way to add functional tests for controllers/routes that aren't in
# the apps directory.
#
# This should be moved to the test directory if possible.
class Tests::PretendController < ApplicationController
  include Cms::Acts::ContentPage
  
  requires_permission_for_section "/members", :only=>[:restricted]

  RESTRICTED_H1 = "Restricted"

  def restricted
    render :text =>"<h1>#{RESTRICTED_H1}</h1> You can see this restricted page."
  end

  def open
    render :text =>"<h1>Open Page</h1> You can see this public page."   
  end

  def error
    raise StandardError     
  end

  def not_found
    raise ActiveRecord::RecordNotFound.new("This thing was missing!")
  end

  def open_with_layout
    render :layout=>"templates/subpage"
  end
end
