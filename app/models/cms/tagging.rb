module Cms
  class Tagging < ActiveRecord::Base
    belongs_to :tag, :class_name => 'Cms::Tag'
    belongs_to :taggable, :polymorphic => true, :class_name => 'Cms::Taggable', :foreign_type => 'taggable_type'

    include DefaultAccessible
    attr_accessible :tag, :taggable

    def content_type
      Cms::ContentType.first(:conditions => {:name => taggable_type})
    end

  end
end