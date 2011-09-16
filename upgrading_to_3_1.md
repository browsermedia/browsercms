Bugs
----

* Adding a portlet to a page: User ends up on the View Portlet rather than the View Page. Portlet does not get added to the page
* Portlet templates are not loading the ckeditor

Needs
-----

* Remove warnings for directory creation during `rake test:units`
* Add better messaging for `browsercms demo [NAME]`
* Remove bespin

Big Goals
---------

* Get Asset Pipeline hooked up
* Revamp to use Mountable Engines

Wants (Taking advantage of 3.1)
-----
http://freelancing-gods.com/posts/combustion_better_rails_engine_testing
* Remove jquery and use jquery-rails gem which loads jquery via the assets pipeline.
** Add it as a dependency in gemspec
** Add rake precompile assets
* Creating Modules using Mountable apps
** `rails plugin new [NAME] --mountable` is the command
* Engines - Rework bcms as a mountable engine, using the dummy app. Dummy apps are designed to be run using rails s, which is perfect.
** Generators (like model) within an engine will namespace things properly
** Need to run `rake bcms:install:migrations` to install engine migrations (Handled through install)
** This will also make bcms includable as part of a Gemfile using git
* Migrations have a single 'def change' method now, rather than self.up and self.down
* Use Ancestry gem - It handles automatically turning models into tree via a single column. Would be very very performant in comparison to current behavior.

Ideas
-----
* Allow for multiple view templates for blocks.

3.1 Misc
* Rspec Request Tests = Integration/acceptance tests using capabara


Start HERE
----------

