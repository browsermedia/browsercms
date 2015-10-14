module Cms
  module UsersService
    module CmsUserCompatibilityModule

      def cms_user_compatible?
        true
      end

      def enable_able?
        false
      end

      def disable_able?
        false
      end

      def password_changeable?
        false
      end

      def expired?
        false
      end

      # add expected columns to objects
      def self.extended(base)
        unless base.respond_to? :login
          base.send :alias_method, :login, Cms.user_key_field.to_sym
        end

        unless base.respond_to? :full_name
          base.send :alias_method, :full_name, Cms.user_name_field.to_sym
        end
      end

      def guest?
        false
      end

      # COLUMN based

      def full_name_with_login
        "#{full_name} (#{login})"
      end

      def full_name_or_login
        if full_name.strip.present?
          full_name
        else
          login
        end
      end

      # Permissions

      def groups_with_cms_access
        groups.cms_access
      end

      def permissions
        @permissions ||= load_permissions
      end

      def viewable_sections
        @viewable_sections ||= load_viewable_sections
      end

      def modifiable_sections
        @modifiable_sections ||= load_modifiable_sections
      end

      # Expects a list of codes of Permissions
      # true if the user has any of the permissions
      def able_to?(*required_permissions)
        perms = required_permissions.map(&:to_sym)
        permissions.any? do |p|
          perms.include?(p.name.to_sym)
        end
      end

      # Determine if this user has permission to view the specific object. Permissions
      #   are always tied to a specific section. This method can take different input parameters
      #   and will attempt to determine the relevant section to check.
      # Expects object to be of type:
      #   1. Section - Will check the user's groups to see if any of those groups can view this section.
      #   2. Path - Will look up the section based on the path, then check it.  (Note that section paths are not currently unique, so this will check the first one it finds).
      #   3. Other - Assumes it has a section attribute and will call that and check the return value.
      #
      # Returns: true if the user can view this object, false otherwise.
      # Raises: ActiveRecord::RecordNotFound if a path to a not existent section is passed in.
      def able_to_view?(object)
        section = object
        if object.is_a?(String)
          section = Cms::Section.find_by_path(object)
          raise ActiveRecord::RecordNotFound.new("Could not find section with path = '#{object}'") unless section
        elsif !object.is_a?(Cms::Section)
          section = object.parent
        end
        viewable_sections.include?(section) || cms_access?
      end

      def able_to_modify?(object)
        case object
        when Cms::Section
          modifiable_sections.include?(object)
        when Cms::Page, Cms::Link
          modifiable_sections.include?(object.section)
        else
          if object.class.respond_to?(:connectable?) && object.class.connectable?
            object.connected_pages.all? { |page| able_to_modify?(page) }
          else
            true
          end
        end
      end

      # Expects node to be a Section, Page or Link
      # Returns true if the specified node, or any of its ancestor sections, is editable by any of
      # the user's 'CMS User' groups.
      def able_to_edit?(object)
        able_to?(:edit_content) && able_to_modify?(object)
      end

      def able_to_publish?(object)
        able_to?(:publish_content) && able_to_modify?(object)
      end

      def able_to_edit_or_publish_content?
        able_to?(:edit_content, :publish_content)
      end

      def cms_access?
        groups.cms_access.present?
      end

      private

      def load_permissions
        Cms::Permission.by_group_ids groups.map(&:id)
      end

      def load_viewable_sections
        Cms::Section.by_group_ids groups.map(&:id)
      end

      def load_modifiable_sections
        Cms::Section.by_group_ids groups_with_cms_access.map(&:id)
      end
    end
  end
end