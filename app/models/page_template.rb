class PageTemplate < DynamicView

  validates_format_of :name, :with => /\A[a-z]+[a-z0-9_]*\Z/, :message => "can only contain lowercase letters, numbers and underscores and must begin with a lowercase letter"

  def file_path
    File.join(self.class.base_path, "layouts", "templates", file_name)
  end
  
  def self.default_body
    html = <<HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <title><%= @page_title %></title>
    <%= yield :html_head %>
  </head>
  <body>
    <%= cms_toolbar %>
    <%= container :main %>
  </body>
</html>
HTML
    html
  end
  
end
