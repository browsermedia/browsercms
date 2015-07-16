require 'cms/users_service/cms_login_user_controller_concern'
require 'cms/users_service/users_factory'
require 'cms/users_service/guest_user_module'
require 'cms/users_service/cms_user_compatibility_module'
require 'cms/users_service/user_groups_by_codes_module'

module Cms
  module UsersService

    GUEST_NAME           = 'Anonymous User'
    GROUP_CMS_ADMIN      = 'cms-admin'
    GROUP_CONTENT_EDITOR = 'content-editor'

    # dirty trick needed for compatibility issues
    # https://amitrmohanty.wordpress.com/2014/01/20/how-to-get-current_user-in-model-and-observer-rails/
    def self.current
      Thread.current[:cms_user]
    end

    def self.current=(user)
      Thread.current[:cms_user] = user
    end

    def self.use_user_by_login(login, group_codes: nil)
      use_user UsersFactory.user(login, group_codes: group_codes)
    end

    def self.use_user(user, group_codes: nil)
      self.current = UsersFactory.extend_user(user, group_codes: group_codes)
    end

    def self.use_guest_user
      self.current = UsersFactory.extend_user(UsersFactory.guest_user)
    end

    def self.controller_module
      CmsLoginUserControllerConcern
    end

    def self.user_compatibility_module
      CmsUserCompatibilityModule
    end
  end
end