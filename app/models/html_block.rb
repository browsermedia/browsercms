class HtmlBlock < ActiveRecord::Base
  include Cms::BlockSupport
  def render
    content
  end
  
end