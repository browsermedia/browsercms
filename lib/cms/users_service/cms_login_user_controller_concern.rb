module Cms
  module UsersService
    module CmsLoginUserControllerConcern
      extend ActiveSupport::Concern

      def cms_login_user_by_login(login, group_codes: nil)
        Cms::UsersService.use_user_by_login login, group_codes: group_codes

        sign_in :cms_user, Cms::UsersService.current
      end

      def cms_login_user_by_user(user, group_codes: nil)
        Cms::UsersService.use_user user, group_codes: group_codes

        sign_in :cms_user, Cms::UsersService.current
      end
    end
  end
end