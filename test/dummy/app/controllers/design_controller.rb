class DesignController < ApplicationController
  def show
    render params[:page], layout: 'design_layout'
  end
end
