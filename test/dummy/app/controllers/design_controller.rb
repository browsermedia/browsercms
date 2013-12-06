# Can be removed after design integration is completed.
class DesignController < ApplicationController
  def show
    render params[:page], layout: 'design_layout'
  end
end
