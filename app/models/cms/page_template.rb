class PageTemplate < DynamicView

  validates_format_of :name, :with => /\A[a-z]+[a-z0-9_]*\Z/, :message => "can only contain lowercase letters, numbers and underscores and must begin with a lowercase letter"

  def file_path
    File.join(self.class.file_path, file_name)
  end
  
  def self.relative_path
    File.join("layouts", "templates")
  end
  
  def self.file_path
    File.join(base_path, relative_path)
  end
  
  def self.default_body
    html = <<HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <title><%= page_title %></title>
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
  
  def self.display_name(file_name)
    name, format, handler = file_name.split('.')
    "#{name.titleize} (#{format}/#{handler})"
  end
  
  # This is a combination of file system page templates 
  # and database page templates
  def self.options
    file_system_templates = ActionController::Base.view_paths.map{|p| Dir["#{p}/#{relative_path}/*"]}.flatten.map{|f| File.basename(f)}
    page_templates = file_system_templates + all.map{|t| t.file_name }
    page_templates.map{|f| [display_name(f), f] }.sort.uniq
  end
  
end
