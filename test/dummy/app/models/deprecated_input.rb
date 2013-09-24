class DeprecatedInput < ActiveRecord::Base
  acts_as_content_block taggable: true
  content_module :deprecated_inputs
  belongs_to_category
  has_attachment :cover_photo
  has_many_attachments :photos

  # For testing template_editor input
  def self.render_inline
    true
  end

  def template_handler
    "erb"
  end

  def self.default_template
    "<html></html>"
  end
end
