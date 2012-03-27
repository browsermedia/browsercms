#require 'cms/version'

# Used for some misc configuration around the project.
module Cms

  class << self

    attr_accessor :attachment_file_permission

    # Determines which WYSIWYG editor is the 'default' for a BrowserCMS project
    #
    # bcms modules can changes this by overriding it in their configuration.
    def content_editor
      @wysiwig_editor ||= "ckeditor"
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
  end
end

Time::DATE_FORMATS.merge!(
	:year_month_day => '%Y/%m/%d',
	:date => '%m/%d/%Y'	
)


