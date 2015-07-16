module Cms
  module UsersService
    module GuestUserModule
      def guest?
        true
      end

      def readonly?
        true
      end

      def cms_access?
        false
      end

      def groups
        @groups ||= Cms::Group.guest_groups.includes(:permissions)
      end

      def group
        groups.first
      end

      def able_to_edit?(_section)
        false
      end

      #You shouldn't be able to save a guest user (but do not fail, as in original BrowserCMS)
      def update_attribute(_name, _value)
        false
      end

      def update_attributes(_attrs = {})
        false
      end

      def save(_perform_validation = true)
        false
      end
    end
  end
end