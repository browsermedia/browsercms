module Cms
  module UsersService

    module UserGroupsByCodesModule
      attr_accessor :group_codes

      def groups
        @groups ||= Cms::Group.with_code(group_codes).includes(:permissions)
      end
    end

  end
end
