class HtmlBlock < ActiveRecord::Base

  acts_as_content_block :taggable => true
  
  validates_presence_of :name
  
  # Override of search scope from searching behavior to deal with include_body 
  named_scope :search, lambda{|search_params|
    term = search_params.is_a?(Hash) ? search_params[:term] : search_params  
    order = search_params.is_a?(Hash) && search_params[:order] ? search_params[:order] : "html_blocks.name"
    include_body = search_params.is_a?(Hash) ? search_params[:include_body] : false
    conditions = []
    columns = ["name"]
    columns << "content" if include_body
    unless term.blank?
      columns.each do |c|
        if conditions.empty?
          conditions = ["lower(#{table_name}.#{c}) like lower(?)"]
        else
          conditions.first << "or lower(#{table_name}.#{c}) like (?)"
        end
        conditions << "%#{term}%"
      end
      conditions[0] = "(#{conditions[0]})"
    end
    scope = {}
    scope[:conditions] = conditions if conditions
    scope[:order] = order if order
    scope
  }
  
  def self.display_name
    "Text"
  end

  def self.display_name_plural
    "Text"
  end
  
end