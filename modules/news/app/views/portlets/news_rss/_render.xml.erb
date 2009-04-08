xml.instruct! :xml, :version=>"1.0" 
xml.rss(:version=>"2.0") do
  xml.channel do
    xml.title("Articles")
    xml.link("/news/rss")
    xml.description("")
    xml.language('en-us')
      for article in @articles
        xml.item do
          xml.title(article.name)
          xml.description(article.summary) unless article.summary.blank?             
          xml.pubDate(article.release_date.strftime("%a, %d %b %Y %H:%M:%S %z")) unless article.release_date.blank?
          xml.link(news_articles_path(article.details_params))
          xml.guid(news_articles_path(article.details_params))
        end
      end
  end
end
