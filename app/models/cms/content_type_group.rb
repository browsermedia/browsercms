module Cms
  class ContentTypeGroup < ActiveRecord::Base
    attr_accessible :name

    has_many :content_types, :order => "#{ContentType.table_name}.id", :class_name => 'Cms::ContentType'

    has_many :types, :order=>"priority, name", :class_name => 'Cms::ContentType'

    def self.menu_list
      order(:id).all
    end


  end
end