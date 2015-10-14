module Cms
  class DefaultUser < ActiveRecord::Base
    self.table_name = "cms_default_users"
    include Cms::UsersService.user_compatibility_module
  end
end