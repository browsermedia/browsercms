module Cms
  class TagsController < Cms::ContentBlockController
    def index
      load_blocks
      respond_to do |format|
        format.html
        format.json { render :inline => @blocks.map { |e| e.name }.to_json }
      end
    end

    def show
      redirect_to tags_path
    end

  end
end
