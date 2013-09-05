module Cms
  class HtmlBlock < ActiveRecord::Base

    acts_as_content_block :taggable => true
    content_module :core

    # This shouldn't be necessary but it is for browsercms.seeds.rb'
   #attr_accessible :name, :content

    validates_presence_of :name

    def self.eager_matching(term)
      "%#{term}%"
    end
    # Override of search scope from searching behavior to deal with include_body
    def self.search(search_params)
      term = search_params.is_a?(Hash) ? search_params[:term] : search_params
      include_body = search_params.is_a?(Hash) ? search_params[:include_body] : false


      conditions = ["name like lower(?)", eager_matching(term)]
      if include_body
        conditions[0] << "OR content like lower(?)"
        conditions << eager_matching(term)
      end
      where(conditions)
    end

    def self.display_name
      "Text"
    end

    def self.display_name_plural
      "Text"
    end

  end
end