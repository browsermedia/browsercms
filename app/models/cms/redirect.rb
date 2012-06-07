module Cms
  class Redirect < ActiveRecord::Base
    validates_presence_of :from_path, :to_path
    validates_uniqueness_of :from_path

    def self.from(path)
      where(:from_path => path).first
    end

    attr_accessible :from_path, :to_path
  end
end