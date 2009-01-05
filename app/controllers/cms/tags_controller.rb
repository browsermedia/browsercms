class Cms::TagsController < Cms::ApplicationController
  def index
    @tags = Tag.all(:order => "name")
    respond_to do |format| 
      format.js { render :inline => "var tags = #{@tags.map(&:name).to_json}" }
    end
  end
end