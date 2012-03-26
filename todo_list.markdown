Tasks:

** Clean up and eliminate the cms/init.rb file (once tests are fixed)

## Upgrade Notes
- Migrations are now generated with .cms. Will this cause problems during upgrades? (Write upgrade scenarios)
- rails -h only provides generate | destroy methods with engine on a new project. Why? It sucks to have to cd into test/dummy to run tests.


# 3.5.x Goals

* Paperclip Based Assets - Replace the existing 'custom' file upload behavior with one that uses Paperclip. Allow blocks to have more than one attachment.
* Mobile Templates - Allow developers to define optional mobile templates for pages that can be shown to mobile devices.
* Faster Files - Take advantage of X-Sendfile (if possible) to speed up sending uploaded CMS files.
* Browser Compatibility Testing - Ensure compatibility with latest versions of Chrome/IE 9/Firefox/Safari. IE 9 probably needs the most works.

# 3.4.1

* [CMS] Upgrade a 3rd module (with a migration) to confirm the installation and upgrade instructions work correctly.
* browsercms-cucumber - Build a separate gem from this project, which can be included in other CMS projects. (Might be 3.4.1)
* Refactor Cucumber steps to add seed data once as part of the env.rb file, then use truncation to leave it there.
* If user's try to add to a Rails 3.2 project, it will blow up midway through (i.e. the jquery-rails dependency will fail since R3.2 require jquery-rails-2.0. A better plan would be to fail fast.
* Profile Cucumber Scenarios to speed them up.
    - cuke --format usage (http://stackoverflow.com/questions/1265659/profiling-a-cucumber-test-ruby-rails)
    - Slowest Scenarios: http://itshouldbeuseful.wordpress.com/2010/11/10/find-your-slowest-running-cucumber-features/ (Might be unnecessary as compared to previous


# Future

* How much value is there to allow users to pick the table prefix (as compared to the complexity it brings). Would it be better to just force everything to cms_?
* Add Block.publish and publish! for easier coding. (or just make default for blocks to be published via code and not via UI)
* Internal CMS layouts (like _head.html.erb) do not take advantage of the asset pipeline to join all css or js files (most are compiled into cms/application.css though)
* Improve generators for assets from engines (Review http://bibwild.wordpress.com/2011/09/20/design-for-including-rails-engine-assets-into-pipeline-manifest/)
* Remove the styled_file_field (no longer maintained)
* Themes can be packaged as assets as well (I think?). Rework bluesteel so its part of the asset pipeline.
* Design how a portlet can include a single jquery based library by just declaring it in the render.html.erb.
** eg. auto_discovery_link_tag -> Does not get included in the head
* Allow for multiple view templates for blocks.
* Look at Papertrail and see how they structure versions. Their API seems every simple for single blocks.
* Clean up logging messages that are filling up the production logs unnecessarily
** 'Caching enabled'
** 'Not the CMS site'
** 'Rendering content block X'
** 'Not caching, user logged in'
** Rendering template X'
** Have at most one line per request for any diagnostic result.
* Upgrade jquery.selectbox-0.5 to jquery.sb.js (https://github.com/revsystems/jQuery-SelectBox). This will likely improve the usability of the selectbox.

## Better Testing of Production/Env

### Using Pow
Configure a CMS application to boot in production mode (temporarily for testing)

echo export RAILS_ENV=production > .powenv && touch tmp/restart.txt - From https://github.com/37signals/pow/wiki/FAQ