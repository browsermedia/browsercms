# Working on release of bcms 3.4

Current:
* Move 'datepicker' initialization into application.js

* Test upgrading a browsercms 3.3.x to 3.4.x
* Write upgrade notes

Tasks:

* [CMS] Upgrade a 3rd module (with a migration) to confirm the installation and upgrade instructions work correctly.
* Write upgrade instructions from 3.1.x/3.3.x to 3.4
* Update Roadmap (https://github.com/browsermedia/browsercms/wiki/Roadmap)

## Notes (for upgrading engines)

2. Adding seed data (either later or before) should always require the same installation commands (i.e. rake db:install if possible) Don't force developers to remember multiple commands
3. Gemspec should be generated more suitably to an engine (less exceptions). Alternatively, write better clean up instructions for upgrading modules.
4. By default, Rails wants to match the table names of namespaced models (i.e. BcmsNews::NewsArticle). This can make for somewhat LONG and/or redudant table names (i.e. bcms_news_news_articles) but is probably better in the long run since it helps uniquely tie table to their module.
5.  The BrowserCMS convention of having 'create_versioned_table' do different things based on the underlying model is might be flawed. Migrations really need to represent a snapshot in time that won't change based on the code. Case in point, we don't know what column name is being generated for original_record_id.

# Bugs
* If a content type can't be found in code, the entire /cms/content_library will throw an error. This could be made more robust by just not showing the content type. This probably only happens when we upgrade databases for testing, but its still annoying.


# 3.4.1
-------
* browsercms-cucumber - Build a separate gem from this project, which can be included in other CMS projects. (Might be 3.4.1)
* Refactor Cucumber steps to add seed data once as part of the env.rb file, then use truncation to leave it there.
* If user's try to add to a Rails 3.2 project, it will blow up midway through (i.e. the jquery-rails dependency will fail since R3.2 require jquery-rails-2.0. A better plan would be to fail fast.


# Wants (Taking advantage of Rails 3.1)

* How much value is there to allow users to pick the table prefix (as compared to the complexity it brings). Would it be better to just force everything to cms_?
* Fix forms layouts in Chrome (Instructions cause a problem)
* Add Block.publish and publish! for easier coding. (or just make default for blocks to be published via code and not via UI)
* Internal CMS layouts (like _head.html.erb) do not take advantage of the asset pipeline to join all css or js files (most are compiled into cms/application.css though)
* Improve generators for assets from engines (Review http://bibwild.wordpress.com/2011/09/20/design-for-including-rails-engine-assets-into-pipeline-manifest/)
* Remove the styled_file_field (no longer maintained)
* Themes can be packaged as assets as well (I think?). Rework bluesteel so its part of the asset pipeline.
* Run in production mode locally (for better error testing). Try POW to see if that adds subdomains easily.
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

 Determine if there is a more conventional pattern for applying seed data as part of an engine.
  From Docs...

  # If your engine has migrations, you may also want to prepare data for the database in
  # the <tt>seeds.rb</tt> file. You can load that data using the <tt>load_seed</tt> method, e.g.
  #
  #   MyEngine::Engine.load_seed

## Modules to be updated (for Engines)

See the [State of the Modules](https://github.com/browsermedia/browsercms/wiki/State-of-the-Modules) for an up to date listing.


## Better Testing of Production/Env

### Using Pow
Configure a CMS application to boot in production mode (temporarily for testing)

echo export RAILS_ENV=production > .powenv && touch tmp/restart.txt - From https://github.com/37signals/pow/wiki/FAQ