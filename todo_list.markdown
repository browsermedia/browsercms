Working on bcms 3.4

# Needs

* Email a page portlet doesn't work (throws error when you create one) - Add scenarios
* Tag Cloud portlet doesn't work (throws error when you create one) - Add scenarios
* Differ `bundle install` from happening until Gemfile is updated to include bcms
* Improve Performance - Sitemap and serving pages is particularly slow
** Use Ancestry gem - It handles automatically turning models into tree via a single column. Would be very very performant in comparison to current behavior.
* Update a few modules (like bcms_news) to test module generation
* Test this on a production environment prior to releasing (things like assets and/or config options might be wonky)
* Rework a few modules to work with Rails 3.1
* Review the README for accuracy in light of engines and asset pipeline

# Wants (Taking advantage of 3.1)

* Add Block.publish and publish! for easier coding. (or just make default for blocks to be published via code and not via UI)
* Verify that instances of Acts::As::ContentPage in projects can correctly load CMS templates
* Get Aruba working to test the bcms and other functions
* Internal CMS layouts (like _head.html.erb) do not take advantage of the asset pipeline to join all css or js files (most are compiled into cms/application.css though)
* Improve generators for assets from engines (Review http://bibwild.wordpress.com/2011/09/20/design-for-including-rails-engine-assets-into-pipeline-manifest/)
* Remove the styled_file_field (no longer maintained)
* Use 3.1 Migration style: Migrations have a single 'def change' method now, rather than self.up and self.down
* Themes can be packaged as assets as well (I think?). Rework bluesteel so its part of the asset pipeline.
* Run in production mode locally (for better error testing). Try POW to see if that adds subdomains easily.
* Design how a portlet can include a single jquery based library by just declaring it in the render.html.erb.
** eg. auto_discovery_link_tag -> Does not get included in the head
* Add better messaging for `browsercms demo [NAME]`
* Allow for multiple view templates for blocks.
* Look at Papertrail and see how they structure versions. Their API seems every simple for single blocks.
* Clean up logging messages that are filling up the production logs unnecessarily
** 'Caching enabled'
** 'Not the CMS site'
** 'Rendering content block X'
** 'Not caching, user logged in'
** Rendering template X'
** Have at most one line per request for any diagnostic result.
* Move 'datepicker' initialization into application.js
* Upgrade jquery.selectbox-0.5 to jquery.sb.js (https://github.com/revsystems/jQuery-SelectBox). This will likely improve the usability of the selectbox.

## New Features

* Make templating better through the UI
* Make content blocks the same as pages

## Modules to be updated (for Engines)

bcms_news (first one)
bcms_polling
bcms_event
bcms_fckeditor (Needs to correctly use new JS inclusion and may need to generate a customconfig.js)
bcms_content_rotator
bcms_webdav
bcms_cas
bcms_google_mini_search
bcms_page_comments

bcms_fckeditor  - 1.1.0 is pushed to github. Gem needs to be pushed as well. Need to test file upload (browser.xml) from within the browser
* BUG - bcms_news - Recent Archive portlet is throwing errors.
bcms_google_mini_search - 1.2 pushed to github. Gem not released.


### How to upgrade to a Rails Engine

* cd into your project
* Run `rails plugin new . --mountable`
* All the available rake tasks in the App are prefixed as 'app'. So `rake app:db:install`
* Need to copy the migrations from the engine into the application.

