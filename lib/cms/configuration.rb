require 'active_record/errors'

# Used for some misc configuration around the project.
module Cms

  class << self

    attr_accessor :attachment_file_permission

    # Determines which WYSIWYG editor is the 'default' for a BrowserCMS project
    #
    # bcms modules can changes this by overriding it in their configuration.
    def content_editor
      # CKEditor is the default.
      @wysiwig_editor ||= ['bcms/ckeditor_load', 'ckeditor-jquery']
    end

    def content_editor=(editor)
      @wysiwig_editor = editor
    end

    def markdown?
      Object.const_defined?("Markdown")
    end

    def reserved_paths
      @reserved_paths ||= ["/cms", "/cache"]
    end
  end

  module Errors
    class AccessDenied < StandardError
      def initialize
        super("Access Denied")
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


