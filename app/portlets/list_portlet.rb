class ListPortlet < Cms::Portlet

  description "Find and display content blocks."
  enable_template_editor false

  def render
    query = current_content_type.model_class
    limit = self.limit
    unless limit.blank?
      query = query.limit(limit.to_i)
    end
    direction =  self.reverse_order.blank? || self.reverse_order == "0" ? 'asc' : 'desc'
    unless self.order.blank?
      query = query.order("#{self.order} #{direction}")
    end
    @content_blocks = query.all.to_a
  end


  # This is far less flexible than prepending additional view paths, but it suffices for now.
  def view_as_full_path
    if File.exists?(expected_view_path())
      "portlets/list/#{self.name.parameterize('_')}/_#{self.view_as}"
    else
      "portlets/list/_#{self.view_as}"
    end
  end

  def expected_view_path
    File.join(Rails.root, 'app', 'views', 'portlets', 'list', self.name.parameterize('_'), "_#{self.view_as}.html.erb")
  end

  def view_as_path
    "portlets/list/#{self.name.parameterize('_')}/_#{self.view_as}.html.erb"
  end

  def current_content_type
    Cms::ContentType.named(self.content_type).first
  end
end