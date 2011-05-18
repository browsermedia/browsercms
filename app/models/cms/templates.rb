##
# Separated into its own file so it can be required in Application Templates and Generators easier.
module Cms
  module Templates

    ##
    # Generates a basic empty template for a page.
    #
    def self.default_body
      html = <<HTML
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <title><%= page_title %></title>
    <%= yield :html_head %>
  </head>
  <body style="margin: 0; padding: 0; text-align: center;">
    <%= cms_toolbar %>
    <div id="wrapper" style="width: 700px; margin: 0 auto; text-align: left; padding: 30px">
      Breadcrumbs: <%= render_breadcrumbs %>
      Main Menu: <%= render_menu %>
      <h1><%= page_title %></h1>
      <%= container :main %>
    </div>
  </body>
</html>
HTML
      html
    end
  end
end
