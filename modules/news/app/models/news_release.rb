class NewsRelease < ActiveRecord::Base

  include Attachable
  acts_as_content_block
  
  belongs_to :category
  belongs_to :attachment
  
  def year
    release_date ? release_date.year : nil
  end

  def month
    release_date ? release_date.month : nil
  end

  def set_section
    if new_record? && !attachment_file.blank?    
      self.section = Section.first(:conditions => {:name => 'News Release'})
    end
  end
  
  def set_attachment_file_name
    if new_record? && !attachment_file.blank?
      attachment.file_name = "/news_releases/#{Time.now.to_s(:year_month_day)}/#{name.to_slug}.#{attachment_file.original_filename.split('.').last.to_s.downcase}" 
    end
  end

  def renderer(news_release)
    lambda do
      buf = ""
      buf += "<p><b>Name:</b> #{news_release.name}</p>"
      buf += "<p><b>Release Date:</b> #{news_release.release_date}</p>"
      buf += "<p><b>Category:</b> #{news_release.category.name}</p>"
      buf += "<p><b>Attachment:</b> <a href=\"#{news_release.attachment_link}\">#{news_release.attachment_path}</a></p>"
      buf += "<p><b>Summary:</b> #{news_release.summary}</p>"
      buf += "<p><b>Body:</b> #{news_release.body}</p>"
    end

  end

end
