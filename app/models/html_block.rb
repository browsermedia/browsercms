class HtmlBlock < ActiveRecord::Base

  acts_as_content_block
  version_fu
  
  def render
    content
  end

  def self.display_name
    "Html"
  end

  def self.display_name_plural
    "Html"
  end
  
  def revert(version)
    revert_to_version = find_version(version)
    attrs = attributes.keys.reject{|e| ["id", "created_at", "version"].include?(e) }
    attrs.each do |a|
      send("#{a}=", revert_to_version.send(a))
    end  
    save
  end
  
end