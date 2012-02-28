# Working on release of bcms 3.4

Current:

Tasks:

* Refactor Cucumber steps to add seed data once as part of the env.rb file, then use truncation to leave it there.
* Merge 3.3.x into project (performance upgrades)
* rake db:install for existing rails projects (after bcms install) might want to run bcms seed data as separate tasks. How to other gems/projects handle this?
* browsercms-cucumber - Build a separate gem from this project, which can be included in other CMS projects. (Might be 3.4.1)
* Audit the buglist to see what else is getting closed as part of 3.1
* Regenerate documentation as part of build process. Ensure things like is_child_of? get removed automatically.

## Notes (for upgrading engines)

2. Adding seed data (either later or before) should always require the same installation commands (i.e. rake db:install if possible) Don't force developers to remember multiple commands
3. Gemspec should be generated more suitably to an engine (less exceptions). Alternatively, write better clean up instructions for upgrading modules.
4. By default, Rails wants to match the table names of namespaced models (i.e. BcmsNews::NewsArticle). This can make for somewhat LONG and/or redudant table names (i.e. bcms_news_news_articles) but is probably better in the long run since it helps uniquely tie table to their module.
5.  The BrowserCMS convention of having 'create_versioned_table' do different things based on the underlying model is might be flawed. Migrations really need to represent a snapshot in time that won't change based on the code. Case in point, we don't know what column name is being generated for original_record_id.

Things to test:

# Short Term

* Test upgrading a browsercms v3.1.x/3.3.x to 3.4.x
* Write upgrade instructions from 3.1.x/3.3.x to 3.4

# Bugs


* If a content type can't be found in code, the entire /cms/content_library will throw an error. This could be made more robust by just not showing the content type. This probably only happens when we upgrade databases for testing, but its still annoying.
* [DynamicPortlets] If you leave fields blank, they throw errors (and/or grab other default templates)
* By default, a generated file block with an Attachment will need additional code to work correctly (I.e. copy & paste from AbstractFileBlocks)


# Needs

* Fix forms layouts in Chrome (Instructions cause a problem)
* Can't create some portlets - Add scenarios
** Email a page portlet  - ERROR: uninitialized constant EmailPagePortlet::EmailMessage
** Tag Cloud portlet - ERROR: uninitialized constant TagCloudPortlet::Tag
* Test this on a production environment prior to releasing (things like assets and/or config options might be wonky)
* Review the README for accuracy in light of engines and asset pipeline

# Wants (Taking advantage of Rails 3.1)

* Add Block.publish and publish! for easier coding. (or just make default for blocks to be published via code and not via UI)
* Verify that instances of Acts::As::ContentPage in projects can correctly load CMS templates
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
* Move 'datepicker' initialization into application.js
* Upgrade jquery.selectbox-0.5 to jquery.sb.js (https://github.com/revsystems/jQuery-SelectBox). This will likely improve the usability of the selectbox.

 Determine if there is a more conventional pattern for applying seed data as part of an engine.
  From Docs...

  # If your engine has migrations, you may also want to prepare data for the database in
  # the <tt>seeds.rb</tt> file. You can load that data using the <tt>load_seed</tt> method, e.g.
  #
  #   MyEngine::Engine.load_seed

## Modules to be updated (for Engines)

See the [State of the Modules](https://github.com/browsermedia/browsercms/wiki/State-of-the-Modules) for an up to date listing.


