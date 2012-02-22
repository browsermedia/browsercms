require 'cms/data_loader'
include Cms::DataLoader

# Load up data that was created in load seed data migration
Cms::User.current = Cms::User.first(:conditions => {:login => 'cmsadmin'})
root_section = Cms::Section.root.first
home_page = Cms::Page.first(:conditions => {:name => "Home"})

# Apply new templates to core pages
home_page.template_file_name = "home_page.html.erb"
home_page.hidden = true
home_page.publish_on_save = true
home_page.save!

# Fill out a sample site map

# Main Menu
create_section(:docs, :name => "Documentation", :parent => root_section, :path => "/documentation")
create_section(:downloads, :name => "Downloads", :parent => root_section, :path => "/downloads")
create_section(:contribute, :name => "Contribute", :parent => root_section, :path => "/contribute")
create_section(:support, :name => "Support", :parent => root_section, :path => "/support")

create_page(:support, :name => "Support", :path => "/support", :section => sections(:support), :template_file_name => "sub_page.html.erb")
create_page(:forums, :name => "Forums", :path => "/support/forums", :section => sections(:support), :template_file_name => "sub_page.html.erb")
create_page(:docs, :name => "Documentation", :path => "/documentation", :section => sections(:docs), :template_file_name => "sub_page.html.erb")
create_page(:api, :name => "API", :path => "/documentation/api", :section => sections(:docs), :template_file_name => "sub_page.html.erb")
create_page(:downloads, :name => "Downloads", :path => "/downloads", :section => sections(:downloads), :template_file_name => "sub_page.html.erb")
create_page(:gems, :name => "Building a Gem", :path => "/downloads/gems", :section => sections(:downloads), :template_file_name => "sub_page.html.erb")
create_page(:contribute, :name => "Contribute", :path => "/contribute", :section => sections(:contribute), :template_file_name => "sub_page.html.erb")
create_page(:github, :name => "Using Github", :path => "/contribute/github", :section => sections(:contribute), :template_file_name => "sub_page.html.erb")

# Utility Nav
create_section(:util, :name => "Utility Nav", :parent => root_section, :path => "/util_nav", :hidden => true)
create_link(:home, :name => "Home", :url => "/", :section => sections(:util))
create_page(:demo, :name => "Demo", :path => "/util_nav/demo", :section => sections(:util), :template_file_name => "sub_page.html.erb")
create_page(:contact_us, :name => "Contact Us", :path => "/util_nav/contact_us", :section => sections(:util), :template_file_name => "sub_page.html.erb")
create_page(:about, :name => "About Us", :path => "/util_nav/about_us", :section => sections(:util), :template_file_name => "sub_page.html.erb")

# Footer Nav
create_section(:footer, :name => "Footer Nav", :parent => root_section, :path => "/footer_nav", :hidden => true)
create_page(:demo, :name => "Site Map", :path => "/footer_nav/site_map", :section => sections(:footer), :template_file_name => "sub_page.html.erb")
create_page(:contribute, :name => "Privacy Policy", :path => "/footer_nav/privacy_policy", :section => sections(:footer), :template_file_name => "sub_page.html.erb")
create_link(:contact_us, :name => "Contact Us", :url => "/footer_nav/contact_us", :section => sections(:footer))
create_page(:our_office, :name => "Our Office", :path => "/footer_nav/our_office", :section => sections(:footer), :template_file_name => "sub_page.html.erb")

# Marks sections as visiable to everyone
Cms::Group.all.each { |g| g.sections = Cms::Section.all }

# Populate the pages with some content.

welcome_content = "<p>Thank you for trying out this demo site. BrowserCMS is a open source content management system, written in Ruby on Rails.
                    It's designed to be approachable for non-technical users, while allowing designers and developers to productively create
                    great looking sites which feature dynamic functionality</p>
                    <p>This demo site uses a theme (Blue Steel) with two templates (Home and Sub),
                    along with a sample sitemap containing several pages and sections. The template shows how to use the core Template API, which allows
                    designers to create maintainable pages with no limits on layout.
                    </p>"

create_html_block(:welcome, :name => "Welcome to BrowserCMS", :content => welcome_content, :publish_on_save => true)
home_page.create_connector(html_blocks(:welcome), "main")


login = "<p>In order to create or edit content, you will need to log into BrowserCMS.</p>
             <p><a href='/cms'>Login here</a>.</p>
            <p>Enter the following:</p><ul>
            <li>Username: cmsadmin</li><li>Password: cmsadmin</li></ul>"
create_html_block(:login, :name => "Login", :content => login, :connect_to_page_id => home_page.id, :connect_to_container => "side_bar_1")

features = "<p>Here is a list of some of the features that BrowserCMS sports.</p>
                <ul>
                  <li>100% Web Based Interface</li>
                  <li>Group Based Permissions</li>
                  <li>Rich Text Editing</li>
                  <li>Flexible Design Templates</li>
                </ul>
                "
create_html_block(:features, :name => "Features", :content => features, :connect_to_page_id => home_page.id, :connect_to_container => "side_bar_2")


create_html_block(:sidebar, :name => "Sidebar", :content => "<ul><li><a href=\"/\">Home</a></li><li><a href=\"/about\">About Us</a></li></ul>", :publish_on_save => true)
create_html_block(:about_us, :name => "About Us", :content => "We are super fantastic", :publish_on_save => true)

pages(:about).create_connector(html_blocks(:about_us), "main")

create_dynamic_portlet(:recently_updated_pages,
                       :name => 'Recently Updated Pages',
                       :code => "@pages = Cms::Page.all(:order => 'updated_at desc', :limit => 3)",
                       :template => <<-TEMPLATE
<h2>Recent Updates</h2>
<ul>
  <% @pages.each do |page| %><li>
    <%= page.name %>
  </li><% end %>
</ul>
TEMPLATE
)

# Publish all Pages
Cms::Page.all.each { |p| p.publish! }
Cms::Link.all.each { |l| l.publish! }


# Create templates

create_page_template(:home_page,
                     :name => "home_page", :format => "html", :handler => "erb",
                     :body => <<-HTML
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <meta http-equiv="Content-Style-Type" content="text/css" />
    <meta http-equiv="Content-Script-Type" content="text/javascript" />
    <title><%= page_title %></title>
    <%= yield :html_head %>
  <%= stylesheet_link_tag "/themes/blue_steel/stylesheets/style" %>
    <style type="text/css">
    #broad {
    margin-right: 10px;
    width: 635px;
    # height: 520px;
    }
    #broad div.main_wrapper {
    margin: 10px;
    border: 1px solid #CCCCCC;
    height: 237px;
    }
  </style>
  </head>
  <body>
  <%= cms_toolbar %>
    <%= render :partial => "partials/header"%>
      <div id="main">
  <div id="broad" class="wrapper">
    <%= image_tag "/themes/blue_steel/images/splash.jpg", :alt=>"Splash!", :id=>"splash"%>
    <div class="main_wrapper">
      <h2>Welcome to BrowserCMS 3.0</h2>
      <%= container :main %>
    </div>
  </div>
  <div id="narrow" class="wrapper">
    <div class="page_highlight main_wrapper">
      <h3>Login</h3>
      <%= container :side_bar_1 %>
    </div>
    <div class="page_highlight main_wrapper">
      <h3>Features</h3>
      <%= container :side_bar_2 %>
    </div>
  </div>
      </div>
      <div style="clear: both;"></div>
      <%= render :partial => "partials/footer" %>
    </div>
  </body>
</html>

HTML
)

create_page_template(:sub_page,
                     :name => "sub_page", :format => "html", :handler => "erb",
                     :body => <<-HTML
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <meta http-equiv="Content-Style-Type" content="text/css" />
    <meta http-equiv="Content-Script-Type" content="text/javascript" />
    <title><%= page_title %></title>
    <%= yield :html_head %>
    <%= stylesheet_link_tag "/themes/blue_steel/stylesheets/style" %>
  </head>
  <body>
    <%= cms_toolbar %>
      <%= render :partial => "partials/header"%>
      <div id="main">
        <div id="sub_nav" class="nav wrapper">
          <%# Sub Menus: Developers can dynamically render menus for subsections.
            # Here we show all pages/sections starting one level down from the top of the site.
            # All children of the top level section will be shown here in a list. %>
          <%= render_menu :from_top => 1, :depth => 2 %>
        </div>
        <div id="broad" class="wrapper">
          <%# This demonstrates how breadcrumbs can be automatically generated by using helpers.
            # The style of the breadcrumbs is controlled via CSS, which turns the ul/li into horizontal breadcrumbs with separaters. %>
          <!-- Commented out as we don't have styles/design for this yet.
            <%= render_breadcrumbs %>
          -->
          <div class="main_wrapper">
            <h2><%= page_title %></h2>
            <%= container :main %>
          </div>
        </div>
      </div>
      <div style="clear: both;"></div>
      <%= render :partial => "partials/footer" %>
    </div>
  </body>
</html>

HTML
)


# Create partials

create_page_partial(:_footer,
                    :name => "_footer", :format => "html", :handler => "erb",
                    :body => <<-HTML
    <div id="footer" class="nav wrapper">
  <div>
    <p>&copy; 1998-2009 BrowserMedia, LLC. All Rights Reserved</p>
    <a href="/footer_nav/site_map">Site Map</a><span>|</span><a href="/footer_nav/privacy_policy">Privacy Policy</a><span>|</span><a href="">Contact Us</a><span>|</span><a href="/footer_nav/our_office">Our Office</a>
  </div>
</div>
HTML
)

create_page_partial(:_header,
                    :name => "_header", :format => "html", :handler => "erb",
                    :body => <<-HTML
    <div id="content">
  <div id="upper_nav" class="nav">
    <div>
      <a href="/">Home</a><span>|</span>
      <a href="/util_nav/demo">Demo</a><span>|</span>
      <a href="/util_nav/contact_us">Contact Us</a><span>|</span>
      <a href="/util_nav/about_us">About Us</a>
    </div>
  </div>
  <div style="clear: both;"></div>
  <div id="header" class="wrapper">
    <a href="/"><%= image_tag "/themes/blue_steel/images/logo.jpg", :alt=>"logo"%></a>
    <div id="header_text">
      <h1>BrowserCMS 3.0</h1>
      <p>
        The newly redesigned BrowserCMS 3.0 is an easy, affordable<br />
        way to control, edit, and organize website content.
      </p>
    </div>
  </div>
  <div style="clear: both;"></div>
  <div id="mid_nav" class="nav wrapper">
    <%= render_menu :from_top => 0, :depth => 1%>
  </div>

HTML
)


