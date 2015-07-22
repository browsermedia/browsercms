module Cms
  module UsersService
    class UsersFactory
      class << self
        delegate :guest_user, :user, :extend_user, to: :factory
      end

      def self.factory
        @factory || new
      end

      def guest_user
        load_guest_user.tap { |u| extend_user u }
      end

      def user(login, group_codes: nil)
        load_user(login).tap do |user|
          extend_user(user, group_codes: group_codes)
        end
      end

      def extend_user(user, group_codes: nil)
        user.send :extend, CmsUserCompatibilityModule unless user.try :cms_user_compatible?
        user.send :extend, UserGroupsByCodesModule unless user.respond_to? :group_codes=
        add_groups_to_user(user, group_codes) if group_codes
        user
      end

      private
      def add_groups_to_user(user, group_codes)
        user.group_codes = Array(group_codes)
      end

      def load_user(login)
        Cms.user_class.where(Cms.user_key_field => login).first!
      end

      def load_guest_user
        params = {
          Cms.user_key_field  => Cms::Group::GUEST_CODE,
          Cms.user_name_field => GUEST_NAME
        }

        Cms.user_class.new(params).tap do |guest_user|
          guest_user.send :extend, GuestUserModule
        end
      end
    end
  end
end