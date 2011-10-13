# Cleanup

Remove Bespin - Page Templates/Partials are using it.
Remove selenium (way out of date and not working)
Make migrate generation use 3.1 style

Needs
-----

* Add ticket for upgrading to Rails 3.1
* Differ `bundle install` from happening until Gemfile is updated to include bcms
* Remove bespin
* Improve Performance - Sitemap and serving pages is particularly slow
** Use Ancestry gem - It handles automatically turning models into tree via a single column. Would be very very performant in comparison to current behavior.

Wants (Taking advantage of 3.1)
-----

* Improve generators for assets from engines (Review http://bibwild.wordpress.com/2011/09/20/design-for-including-rails-engine-assets-into-pipeline-manifest/)
* Remove the styled_file_field (no longer maintained)
* [#416] Make bcms includable as part of a Gemfile using git
* Migrations have a single 'def change' method now, rather than self.up and self.down
* Themes can be packaged as assets as well (I think?). Rework bluesteel so its part of the asset pipeline.
* Run in production mode locally (for better error testing). Try POW to see if that adds subdomains easily.
* Design how a portlet can include a single jquery based library by just declaring it in the render.html.erb.
** eg. auto_discovery_link_tag -> Does not get included in the head
* Add better messaging for `browsercms demo [NAME]`


Ideas
-----
* Allow for multiple view templates for blocks.
* Look at Papertrail and see how they structure versions. Their API seems every simple for single blocks.

## Modules to be updated (for Engines)

bcms_news (first one)
bcms_polling
bcms_event
bcms_fckeditor (Needs to correctly use new JS inclusion)
bcms_content_rotator
bcms_webdav
bcms_cas
bcms_google_mini_search
bcms_page_comments



### How to upgrade to a Rails Engine

* cd into your project
* Run `rails plugin new . --mountable`
* All the available rake tasks in the App are prefixed as 'app'. So `rake app:db:install`
* Need to copy the migrations from the engine into the application.

