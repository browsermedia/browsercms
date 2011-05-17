module Cms
class Redirect < ActiveRecord::Base
  uses_namespaced_table
  validates_presence_of :from_path, :to_path
  validates_uniqueness_of :from_path
end
end