class Cms::TagsController < Cms::ContentBlockController
  def index
    load_blocks
    respond_to do |format| 
      format.html { render "#{template_directory}/index" }
      format.js { render :inline => "var tags = #{@blocks.map{|e| e.name}.to_json}" }
    end
  end
end