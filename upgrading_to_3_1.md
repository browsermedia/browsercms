# Cleanup

Remove Bespin - Page Templates/Partials are using it.
Remove selenium (way out of date and not working)
Make migrate generation use 3.1 style

Needs
-----

* Design how a portlet can include a single jquery based library by just declaring it in the render.html.erb.
** eg. auto_discovery_link_tag -> Does not get included in the head
* Add better messaging for `browsercms demo [NAME]`
* Remove bespin
* Run in production mode locally. Try POW to see if that adds subdomains easily.
* Differ `bundle install` from happening until Gemfile is updated to include bcms

Wants (Taking advantage of 3.1)
-----
* http://freelancing-gods.com/posts/combustion_better_rails_engine_testing
* Remove the styled_file_field (no longer maintained)
* Creating Modules using Mountable apps
** `rails plugin new [NAME] --mountable` is the command
* Engines - Rework bcms as a mountable engine, using the dummy app. Dummy apps are designed to be run using rails s, which is perfect.
** Generators (like model) within an engine will namespace things properly
** Need to run `rake bcms:install:migrations` to install engine migrations (Handled through install)
** This will also make bcms includable as part of a Gemfile using git
* Migrations have a single 'def change' method now, rather than self.up and self.down
* Use Ancestry gem - It handles automatically turning models into tree via a single column. Would be very very performant in comparison to current behavior.
* Themes can be packaged as assets as well (I think?). Rework bluesteel so its part of the asset pipeline.

Ideas
-----
* Allow for multiple view templates for blocks.
* Look at Papertrail and see how they structure versions. Their API seems every simple for single blocks.

## Modules to be updated:
* bcms_fckEditor will need to be updated to use the new JS inclusion

### How to upgrade to a Rails Engine

* cd into your project
* Run `rails plugin new . --mountable`
* All the available rake tasks in the App are prefixed as 'app'. So `rake app:db:install`
* Need to copy the migrations from the engine into the application.

