module Cms
  class PagePartial < Cms::DynamicView

    before_validation :prepend_underscore

    validates_format_of :name, :with => /\A_[a-z]+[a-z0-9_]*\Z/, :message => "can only contain lowercase letters, numbers and underscores and must begin with an underscore"

    def self.relative_path
      "partials"
    end

    def file_path
      File.join(self.class.base_path, "partials", file_name)
    end

    def self.display_name(file_name)
      name, format, handler = file_name.split('.')
      "#{name.sub(/^_/, '').titleize} (#{format}/#{handler})"
    end

    def prepend_underscore
      if !name.blank? && name[0, 1] != '_'
        self.name = "_#{name}"
      end
    end

    def partial?
      true
    end

    def placeholder
      "_header"
    end

    # Generates hint for editing
    def hint
      "No spaces allowed. Must start with _."
    end
  end
end