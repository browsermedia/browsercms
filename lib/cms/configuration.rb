require 'active_record/errors'

# Used for some misc configuration around the project.
module Cms

  class << self

    attr_accessor :attachment_file_permission

    # Determines which WYSIWYG editor is the 'default' for a BrowserCMS project
    #
    # bcms modules can changes this by overriding it in their configuration.
    # @return [String] The single javascript file to include to load the proper WYSIWYG editor.
    def content_editor
      # CKEditor is the default.
      @wysiwig_editor ||= 'ckeditor'
    end

    def content_editor=(editor)
      @wysiwig_editor = editor
    end

    def markdown?
      Object.const_defined?('Markdown')
    end

    def reserved_paths
      @reserved_paths ||= ['/cms', '/cache']
    end

    def allow_dynamic_views?
      Rails.application.config.cms.allow_dynamic_views
    end

    def allow_guests?
      Rails.application.config.cms.allow_guests
    end

    # User Class
    def user_key_field
      Rails.application.config.cms.user_key_field
    end

    def user_name_field
      Rails.application.config.cms.user_name_field
    end

    def user_class_name
      Rails.application.config.cms.user_class_name
    end

    def user_class
      user_class_name.to_s.constantize
    end

    def user_class_devise_options
      Rails.application.config.cms.user_class_devise_options.dup.tap do |opts|
        if devise_use_cas_only?
          opts.delete :database_authenticatable
          opts.delete :rememberable
          opts.delete :recoverable
          opts.unshift(:cas_authenticatable) unless opts.include? :cas_authenticatable
        end
      end
    end

    def user_cas_extra_attributes_setter
      Rails.application.config.cms.user_cas_extra_attributes_setter
    end

    # DEVISE AND CAS
    def cas_base_url
      Rails.application.config.cms.cas_base_url
    end

    def cas_destination_url
      Rails.application.config.cms.cas_destination_url
    end

    def cas_follow_url
      Rails.application.config.cms.cas_follow_url
    end

    def cas_logout_url_param
      Rails.application.config.cms.cas_logout_url_param
    end

    def cas_login_url
      Rails.application.config.cms.cas_login_url
    end

    def cas_logout_url
      Rails.application.config.cms.cas_logout_url
    end

    def cas_validate_url
      Rails.application.config.cms.cas_validate_url
    end

    def cas_destination_logout_param_name
      Rails.application.config.cms.cas_destination_logout_param_name
    end

    def cas_create_user
      Rails.application.config.cms.cas_create_user
    end

    def cas_enable_single_sign_out
      Rails.application.config.cms.cas_enable_single_sign_out
    end

    def cas_user_identifier
      Rails.application.config.cms.cas_user_identifier
    end

    def user_class_devise_validatable?
      Rails.application.config.cms.user_class_devise_validatable
    end

    def user_class_devise_recoverable?
      Rails.application.config.cms.user_class_devise_recoverable
    end

    def routes_devise_for_options
      opts = Rails.application.config.cms.routes_devise_for_options.dup

      unless opts.key? :class_name
        opts[:class_name] = user_class_name
      end

      opts[:skip] ||= []

      # always skip sessions, we'll add them outside, as BCMS intended.
      # opts[:skip] << :sessions unless opts[:skip].include? :sessions

      unless devise_allow_registrations?
        opts[:skip] << :registrations unless opts[:skip].include? :registrations
      end

      opts
    end

    def routes_devise_sessions_controller
      key = devise_use_cas_only? ? :cas_sessions : :sessions
      cnts = routes_devise_for_options[:controllers] || {}
      controller_name = cnts[key] || "devise/#{key}"

      # remove 'cms/' prefix
      controller_name.gsub /^cms\//, ''
    end

    def devise_use_cas_only?
      !!Rails.application.config.cms.devise_use_cas_only
    end

    def devise_allow_registrations?
      !!Rails.application.config.cms.devise_allow_registrations
    end
  end

  module Errors
    class AccessDenied < StandardError
      def initialize
        super('Access Denied')
      end
    end

    # Indicates no content block could be found.
    class ContentNotFound < ActiveRecord::RecordNotFound

    end

    # Indicates that no draft version of a given piece of content exists.
    class DraftNotFound < ContentNotFound

    end
  end
end

Time::DATE_FORMATS.merge!(
    :year_month_day => '%Y/%m/%d',
    :date => '%m/%d/%Y'
)


