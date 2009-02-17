class NewsArticle < ActiveRecord::Base

  acts_as_content_block :belongs_to_attachment => true, :taggable => true
  
  belongs_to :category

  validates_presence_of :name, :release_date
  
  before_validation :set_slug
  
  def category_name
    category ? category.name : nil
  end
  
  def set_slug
    self.slug = name.to_slug unless name.blank?
  end
  
  def self.prepare_params_for_details!(params)
    release_date_string = "#{params[:month]}/#{params[:day]}/#{params[:year]}"
    release_date = Date.parse(release_date_string)
    news_article = NewsArticle.first(:conditions => ["release_date = ? and slug = ?", release_date, params[:slug]])
    params[:news_article_id] = news_article.id if news_article
  end
  
  def details_params
    {:year => release_date.strftime("%Y"), :month => release_date.strftime("%m"), :day => release_date.strftime("%d"), :slug => slug}
  end
  
  def year
    release_date ? release_date.year : nil
  end

  def month
    release_date ? release_date.month : nil
  end
  
  def set_attachment_section
    if new_record? && !attachment_file.blank?
      attachment.section = Section.first(:conditions => {:name => 'News'})
    end
  end
  
  def set_attachment_file_path
    if new_record? && !attachment_file.blank?
      attachment.file_path = "/news/articles/attachment/#{Time.now.to_s(:year_month_day)}/#{name.to_slug}.#{attachment_file.original_filename.split('.').last.to_s.downcase}" 
    end
  end

  def renderer(news_article)
    lambda do
      buf = ""
      buf += "<p><b>Name:</b> #{news_article.name}</p>"
      buf += "<p><b>Release Date:</b> #{news_article.release_date}</p>"
      buf += "<p><b>Category:</b> #{news_article.category_name}</p>"
      buf += "<p><b>Attachment:</b> <a href=\"#{news_article.attachment_link}\">#{news_article.attachment_file_path}</a></p>"
      buf += "<p><b>Summary:</b> #{news_article.summary}</p>"
      buf += "<p><b>Body:</b> #{news_article.body}</p>"
    end

  end

end
