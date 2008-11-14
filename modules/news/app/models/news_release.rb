class NewsRelease < ActiveRecord::Base

  include Attachable
  acts_as_content_block
  
  
  belongs_to :category
  belongs_to :attachment
  
  


  def set_section
    self.section = Section.first(:conditions => {:name => 'News Release'})
  end
  
  def set_attachment_file_name
    attachment.file_name = "/news_releases/#{Time.now.to_s(:year_month_day)}/#{name.to_slug}.#{attachment_file.original_filename.split('.').last.to_s.downcase}" if new_record?
  end

  def render
    buf = ""
    buf += "<p><b>Name:</b> #{name}</p>"
    buf += "<p><b>Release Date:</b> #{release_date}</p>"
    buf += "<p><b>Category:</b> #{category.name}</p>"
    buf += "<p><b>Attachment:</b> <a href=\"#{attachment_link}\">#{attachment_path}</a></p>"
    buf += "<p><b>Summary:</b> #{summary}</p>"
    buf += "<p><b>Body:</b> #{body}</p>"

  end

end
