module Cms
  module Acts

    # Allows any ActiveRecord object to behave like a Cms User. This is a bit of an experiment being added to 3.4, so
    # so it might be deprecated in a future version if we add something like devise.
    #
    # The use case would be something like:
    #
    #   class AdminUser < ActiveRecord::Base
    #     acts_as_cms_user :groups => [Cms::Group.find_by_code('admin')]
    #   end
    #
    # where groups could be an array, proc, or instance method (as a symbol).
    # Could be used it with authlogic to grant logins and permissions to
    # everyone in a custom model.  It's not quite a drop in authentication
    # schema, but it does make it easier to wire up just about any model to be
    # the current_user on CMS pages.
    module CmsUser
      def self.included(model_class)
        model_class.extend(MacroMethods)
      end

      module MacroMethods
        def acts_as_cms_user(options = {})
          include InstanceMethods

          # Adding a cms_group method to each person object that returns a list of
          # CMS Groups the user belongs to.  Can be set with an array, proc, or
          # instance method on the person.  Defaults to Cms::Group.guest
          define_method "cms_groups" do
            fetch_group_list = Proc.new do
              if options[:groups].nil?
                [Cms::Group.guest]
              elsif options[:groups].kind_of? Array
                options[:groups]
              elsif options[:groups].is_a? Proc
                options[:groups].call(self)
              elsif self.respond_to?(options[:groups])
                self.send(options[:groups])
              else
                raise ArgumentError, "acts_as_cms_user :groups option expected to be of type Array, Proc, or instance method - #{options[:groups].class} found instead"
              end
            end

            @cms_groups ||= begin
              specified = Array(fetch_group_list.call).select { |x| x.kind_of? Cms::Group }
              specified << Cms::Group.guest if specified.empty?
              specified
            end

          end
        end

        module InstanceMethods

          # The following came from Cms::User
          def guest?
            false
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
              section = object.section
            end
            viewable_sections.include?(section) || cms_access?
          end


          # The following came from Cms::GuestUser or Cms::User

          # Expects a list of names of Permissions
          # true if the user has any of the permissions
          def able_to?(*required_permissions)
            perms = required_permissions.map(&:to_sym)
            permissions.any? do |p|
              perms.include?(p.name.to_sym)
            end
          end


          # Guests never get access to the CMS.
          def cms_access?
            false
          end

          # Return a list of the sections associated with this user that can be viewed.
          # Overridden from user so that able_to_view? will work correctly.
          def viewable_sections
            @viewable_sections ||= Cms::Section.find(:all, :include => :groups, :conditions => ["#{Cms::Group.table_name}.id  in (?)", cms_groups.collect(&:id)])
          end

          def permissions
            @permissions ||= Cms::Permission.find(:all, :include => :groups, :conditions => ["#{Cms::Group.table_name}.id  in (?)", cms_groups.collect(&:id)])
          end

          def able_to_edit?(section)
            false
          end

        end
      end
    end
  end
end
