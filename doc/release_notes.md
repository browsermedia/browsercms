v3.5.2
======

* Refactor CKEditor integration to make it easier to support external integrations (like CKFinder/KCFinder modules)
* [#527] Fix bug that prevented editing users/groups/redirects.

v3.5.1
======

* Test with Rails 3.2.5 release
* Update gemspec to enforce Rails 3.2.5 or later (which contains a critical security SQL Injection patch)
* Fix issue with has_attachments (possibly caused by nested_assignment changes in Rails 3.2.5)

v3.5.0
======

This release includes a number of new features, including:

* Improved Attachments
* Mobile Friendly templates
* Rail 3.2 compatibility
* Improved Heroku support

See the upgrade instructions here for existing projects: https://github.com/browsermedia/browsercms/wiki/Upgrading-to-3.5.x-from-3.4.x

Improved Attachments
--------------------

Attachments have been completely reworked to use Paperclip (https://github.com/thoughtbot/paperclip).

* Each block can now have multiple attachments using different styles.
* Attachments can be defined as one to one (has_attachment :image) or be stored as a collection (has_many_attachments :photos).
* Upgrade migrations are provide to migrate file and data for older projects to the new attachment structure.
* New generators have been provided to create content blocks with the new attachment styles.

See this Attachments API guide for more details: https://github.com/browsermedia/browsercms/wiki/Attachments-API

Mobile
------

The CMS can now be configured to serve mobile optimized content, using a mobile subdomain and smart redirecting based on User Agents.

* Mobile Templates: Each template can have a 'mobile' version, which will be used when users request a mobile version of that page.
* Fallback Templates: Any page which lacks a mobile ready template will use the 'full' desktop template when displayed as mobile.
* Mobile Subdomain:  Any requests to the mobile subdomain automatically serve mobile pages. m. is the assumed subdomain.
* Agent Redirection: Users on mobile devices can be automatically redirected to the mobile subdomain. (Handled via Apache User Agent detection.)
* Mobile Site Opt Out: Users on mobile device can opt to be redirected to the desktop site if they want. (Handled via a cookie)
* Mobile caching: The mobile and full sites have their own separate page cache, mean both can be served quickly by Apache.
* View as Mobile: Editors can preview the mobile templates while editing pages in the admin, if a page has a mobile template. Once in 'mobile' mode, all pages should be viewed as mobile until they disable it.

These features are originally from the bcms_mobile module, which has been inlined into the CMS core. See the [Mobile Setup Guide](https://github.com/browsermedia/browsercms/wiki/Setting-up-mobile-sites) for more information.

Improved Heroku Support
-----------------------

To better support deploying BrowserCMS to Heroku, we have put together a new guide: https://github.com/browsermedia/browsercms/wiki/Deploying-to-Heroku which covers what steps are required, as well as some considerations. For example, using Heroku requires storing files on an external service, so we refactored the core CMS and worked on a new Amazon S3 module (bcms_aws_s3) that will integrate with it.

As a side note, the CMS should work with Postgresql as well, based on our testing with Heroku (which uses Postgres by default).

Admin Links
==========
In an engine, you can do the following:

```
# In lib/bcms_your_module/engine.rb
initializer 'bcms_your_module.add_menu_item' do |app|
  app.config.cms.tools_menu << {:menu_section => 'widgets',
								:name => 'List of Widgets',
								:engine=>'bcms_your_module',
								:route_name => 'widgets_path'
							}
end

# In app/controllers/bcms_your_module/widget_controller.rb
class BcmsYourModule::WidgetsController < Cms::BaseController

  layout 'cms/administration'
  check_permissions :administrate

  def index
	@menu_section = 'widgets'
	# Do something interesting
  end
end

# In config/routes.rb
BcmsYourModule::Engine.routes.draw do
  get '/widgets' => 'widgets#index', :as =>:widgets
end
```

X-Sendfile
----------

One way to improve the performance of BrowserCMS is to enable X-Sendfile. Used in conjunction with Web servers like Apache and Nginx, X-Sendfile will allow web servers to handle serving files that have been uploaded into the CMS. Web servers are very well optimized for sending static files, and doing so takes load off the Ruby processes reducing bottlenecks.

To enable X-Sendfile in your application, uncomment one of the following two lines depending on which web server you are using.

```
# In config/environments/production.rb
config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx
```

You will then need to configure your web server to handle X-Sendfile requests. See documentation for [Apache](https://tn123.org/mod_xsendfile/) and [Nginx](http://wiki.nginx.org/XSendfile) for details.

Other Notable Fixes
-------------

* [#493] Add Mobile capability
* [#494] Speed up Cucumber Scenarios
* [#492] Upgrade to be Rails 3.2.x compatible
* [#509] Pagination works for custom blocks now
* [#508] Remove fancy file upload (probably unused and wasn't working anyway)
* [#519] Better support for Amazon/AWS S3
* [#521] Remove SITE_DOMAIN constant in favor of more conventional rails configuration methods
* Add new migration methods to make it easier for modules to namespace their blocks.
* Allow modules to add new links to the Admin tab without overriding views.
* Fixed issue where named page routes couldn't be found in portlet views
* Fixed issue where page routes can't be created in seed data.
* Confirmed that X-Sendfile works

See the [detailed changelog](https://github.com/browsermedia/browsercms/compare/v3.4.0...v3.5.0) for more info.

v3.4.2
======

Maintenance Release

* [#502] Fix issue where Page templates/partials could not be editted through the UI
* [#491] Fix issue where custom blocks couldn't be viewed in page edit mode
* [#470] Fix issue where loading throws errors on some OS's (Ubuntu)


v3.4.1
======

Maintenance Release

* [#490] Fix issue where Javascript errors occured when in Page edit mode

v3.4.0
======

It's done! After roughly a years worth of work, along with some excellent contributions from the community (thanks Brian King, James Prior and Neil Middleton), BrowserCMS 3.4 is done. This release contains two major additions:

1. It's now Rails 3.1.x compatible
2. Mountable App: BrowserCMS can be now be added to existing Rails applications.

Note: We recommend using Ruby 1.9.3 with this release (though Ruby 1.9.2 will probably still work)

Improved Updating
-----------------

A primary goal of this project is have a simple upgrade path for existing projects. As such, we have baked in the support for upgrading your project right into the core tool itself. See the [Upgrade Guide](https://github.com/browsermedia/browsercms/wiki/Upgrading-a-BrowserCMS-project) for more details, but upgrading a CMS project is now (nearly) as simple as running the following command in your project:

    $ bcms upgrade


CMSifying your Rails project
----------------------------

The entire project was reworked to become a Mountable Engine, meaning it should easier to add to an existing Rails project via running the following command in your Rails project. You can now add BrowserCMS to your Rails 3.1.x project by running:

    $ bcms install

Integrating with the CMS
------------------------

Once the CMS is installed, you can integrate with the existing templates, users, groups and pages. See [Adding BrowserCMS to an existing Rails project](https://github.com/browsermedia/browsercms/wiki/Adding-BrowserCMS-to-an-existing-Rails-project) for details on how you can integrate them. While User authentication/authorization is definitely something that needs more refinement, this release adds some support for modifying your existing User objects to behave as though they were a CMS User (and get access to CMS pages, etc).

Namespacing/Prefixing
---------------------

* Most core files in the CMS are namespaced under Cms:: . This should reduce the chance of conflicting classes (i.e. what was User is now Cms::User)
* Table names can optionally be namespaced. By default, there is no namespace for standalone BrowserCMS projects. You can set: Cms.table_prefix = "cms_" to change this.
* Prefixing tables will be reflected in cms migrations (like create_content_table) automatically. Passing :prefix=>false will add no prefix.
* When defining migrations for cms tables, (using create_table), you can use prefix() to apply the current prefix. i.e.

    create_table prefix(:users)

Other Notable Fixes
-------------------
* [#301] New `bcms upgrade` script for updating BrowserCMS projects.
* [#433] Starting new projects should work regardless of whether later versions of Rails are installed (i.e. Rails 3.2).
* [#3] Asset Pipeline: All bcms assets are now served using the assets pipeline.
* [#443] Removed two primitive javascript and stylesheets in favor of asset pipeline (where needed).
* [#448] Mountable Engines - BrowserCMS is now a mountable engine, which should make integrating it with other projects easier.
* [#416] BrowserCMS can be added to Gemfiles using :git or :path, which should make testing gems or projects easier.
* [#480] Standardized Version Column - Changed how version tables point back to their 'original' record to make working with namespaces easier. Module developers will need to update their migrations for the next release of their modules.
* [#466] Generate blocks with attachments correctly - When generating blocks that have an attachment, the initially generated code should work correctly without addition customization or tweaking.
* [#450] Generate Engines - BrowserCMS modules are created as Mountable Engines when running `bcms module`.
* [#487] CKEditor Gem - Replace the built in CKeditor gem with the Asset pipeline aware ckeditor_rails gem.

See the [detailed changelog](https://github.com/browsermedia/browsercms/compare/v3.3.3...v3.4.0) for a complete list of changes, as well as the [Closed Tickets for 3.4.0](https://github.com/browsermedia/browsercms/issues?milestone=1&state=closed) for a complete list of closed items.

v3.3.4
======

Maintenance release

* [#503] - Searching and sort content blocks works
* [#472] - Sorting content blocks works

v3.3.3
======

Performance! - This merges the performance tuning updates originally added in 3.1.5. See those release notes for details.

v3.3.2
======

This is a maintenance release for the Rails 3.0 branch of BrowserCMS. It should simplify starting new projects and deploying them into production. In bcms-3.3.1, there were a number of configuration changes that were required before sites could be deployed. The 'correct' settings should now be generated when new BrowserCMS projects are created.

If developers still have issues deploying projects into production with this release, please report them on the mailing list. Note that deploying to Heroku is still going to require additional steps.

Details
-------
See https://github.com/browsermedia/browsercms/issues?sort=created&direction=desc&state=closed&page=1&milestone=5 for complete details, but here are highlights.

* [#425] db:install should now correctly setup the database in production mode (without needing to edit seeds.rb)
* [#412] Page caching directory should work on more hosting setups.
* [#409] [#427] Added the correct defaults to production.rb so manually editing it before deploying shouldn't be necessary
* [#406] Fixed a bug where having a Link as the first item in a section would throw errors.
* [#428] Updated the Deployment Guide (https://github.com/browsermedia/browsercms/wiki/Deployment-Guide) to reflect the necessary steps.

v3.3.0
======

Final release is ready. Includes all the Rails 3 goodness, as well as an improve command line tool.

   bcms new cool_new_project
   bcms demo i_want_my_own_app_template -m http://example.com/app_template.rb
   bcms module bcms_pet_store -d mysql

Details
-------
* New commandline syntax described here: https://github.com/browsermedia/browsercms/wiki/Getting-Started
* Removed guides from core project in favor of moving to Github's wiki
* Updated API docs so YARD is being used, and hosted at http://rubydoc.info/gems/browsercms/


v3.3.0.beta
===========

The long awaited Rails 3 release. We have completely reworked BrowserCMS to work with Rails 3 and Ruby 1.9.2. This release is a 'beta', so that folks can start testing against it. This is especially important for module authors, as any modules need to be upgraded to work with Rails 3 as well. Our next steps will be to collect feedback for a final 3.3.0 release/release candidate. If we can get most of the 'core' modules (News, Blog, etc) updated and working, that will likely mean a final 3.3.0 release.

To get this do:

	gem install browsercms --pre

Then generate a new project using the same command as before:

	bcms my_bcms_project
	cd my_bcms_project
	rails s

Features:
--------
* Rails 3!!! : BrowserCMS now uses and requires Rails 3 (3.0.5 or later). We are also requiring Ruby 1.9.2, though 1.8.7 is 'close' to working.
* Engines: Both BrowserCMS and Module are now full blown Rails engines, and we have updated the 'module' template so its correctly generates engines.
* Module Upgrade script: Since all existing modules will require updating, we have provided a commandline script 'bcms-upgrade' to help manage it. Works similarly to how Rails Upgrade does: (https://github.com/jm/rails-upgrade/). Run 'bcms-upgrade check' in your project to get started.
* Project Upgrades: The 'bcms-upgrade' tool also has some support for handling upgrades, however its less comprehensive than the module support. See https://github.com/browsermedia/browsercms/wiki/Upgrading-a-BrowserCMS-project for details on what's involved in upgrading a project to BrowserCMS 3.3/Rails 3.
* Module Installer: After you download a module (i.e. gem install) which is bcms-3.3 compatible, you can now install that modules easily via rails generate cms:install bcms_news . This take care of adding the gem to your project, copying migrations and adding routes. It should no longer be necessary to call 'script/generate browser_cms' everytime you add a new module.
* Asset Packaging: All CMS static assets (js, images, html, etc) are now served directly from the BrowserCMS gem, as well as Modules. They are no longer copied into projects, and should make it much easier to keep track of whether a file has been altered/overridden. Any unaltered copied file can be safely deleted from any projects that upgrade to 3.3.
* JQuery Updates: Core JQuery libraries packaged with BrowserCMS are updated to v1.5.1. As part of this, several libraries have been removed as obsolete or unused, including jquery.dimensions, jquery.contextMenu and jquery.thickbox.
* New Generators: In addition to the new module installer, to fit with the Rails 3 way of 'namespacing' generators, the existing generators have been slightly renamed, specifically:
	* rails generate cms:content_block  	(Was script/generate content_block)
	* rails generate cms:portlet  			(Was script/generate portlet)
	* rails generate cms:template			(Was script/generate template)
	
Bug Fixes:
---------
* #386 - Date Picker - Fixed inconsistent formatting where sometimes dates would appear with timestamps. In order to be both 1.8.7 and 1.9.2 compatible, all datepicker dates are now formatted as YYYY-mm-dd.
* #357 - Page path generator should not replace apostrophes with hyphens enhancement
* #298 - Dashboard errors when clicking complete tasks without selecting any tasks
* #346 - Connected pages returning historic results
* #345 - Pages with trailing slashs can cause issues.
* #352 - Revert to old Page Version Bug versioning

This release essentially merged the changes from 3.2.0 into 3.3.0 for a single release, so thanks to the folks that contributed bug patches for that.

Issues?
------

If you encounter issues with this build, please report them for the 3.3.0.rc1 here: https://browsermedia.lighthouseapp.com/projects/28481/milestones/105840-330rc1

v3.1.5
======

Performance Upgrades - This release adds a number of improvements designed to greatly improve the performance for larger sites (with thousands of pages/sections/attachments). The project now depends on the ancestry gem, which is used to handle the parent/child relationship between Sections/pages in a much more efficent way.

* #432 - Sitemap - The sitemap load time has been greatly reduced for larger sites. Load times of 60s or more with multiple thousands of pages/attachments should be reduced to several sections (2-3s). The number of queries (which could have been in the thousands before) is now ~9 and won't increase as the number of pages increase. There could still be further efficency gains from loading less data overall (i.e. non-open sections), but that will be for a future version.
* Pages - Viewing individual pages should also be faster, again by reducing the number of queries required to load the menus.
* Content Library - The load time of the most frequently hit content library pages (Text, File, Image, Portlet) should be faster.
* Indexes - A number of database indexes for the most commonly used core table/queries for the major pages have been added. In some cases, further indexes may/may not have advantage due to how database's (i.e. MySQL) handle optimization.

v3.1.3
======

Small fix to get rid of a troublesome bug with reverting.

Bug Fixes
* #352 - Reverting pages with connected blocks should now work.

v3.1.2
======

This is a small release which fixes a serious security patch. It is highly recommended that users update to this version.

Lighthouse ticket #'s:
* #314 - Page Templates and Partials will now 'page' if there are > 15 of them.
* #363 - Security patch that closes a security hole that would allow unauthorized users to delete portlets. Special thanks to Jan Schulz-Hofen for identifying the vulnerability and providing a patch for this.



Bug Fixes
* #352 - Reverting pages with connected blocks should now work.

v3.1.0
======

BrowserCMS 3.1 is done! The release has a few exciting new features/refinements as well as its share of bug fixes. As always, you can get it by running 'gem install browsercms', and follow the upgrade guide on the wiki. Please report any errors found to our bug tracking system: https://browsermedia.lighthouseapp.com/projects/28481-browsercms-30

Notable Features:
-----------------

1. New Html Editor: (LH #150) The default editor packaged with BrowserCMS is now CKEditor, which is the upgraded version of FCKEditor. CKEditor supports new features, polish and performance. For developers that still want to use FCKEditor any reason, we have made available a bcms_fckeditor module for continuity purposes. Installing the bcms_fckeditor module will switch the default editor back.
2. Easier project creation: (LH #234) You can now create a new BrowserCMS project by typing 'bcms name_of_project' or 'browsercms name_of_project'. The command line tool is really just thin wrappers around 'rails' that invoke the application templates from within the gem itself. Run 'bcms' for more complete help tips, or http://patrickpeak.com/wordpress/2010/01/incoming-browsercms-commandline-script/ for a more indepth write up.
3. Improved Portlet Workflow: (LH #180) Portlets now default to having their templates not be editable via the UI. There is an easy on/off option on the portlet to turn editing back on. This will allow for developers to more rapidly refine their views, with the option to easily make them editable when complete.
4. Improved Documentation:  We have updated the guides to match 3.1 features (especially 'Getting Started' - LH #272). There is also several new guides, including a more detailed exploration of Content Blocks and creating Templates (LH #287). All guides can now be found at http://guides.browsercms.org. API docs can be found at http://api.browsercms.org.
5. Controllers that act like Pages: (LH #202) - Added a more refined way for developers to create their own controllers that can behave like CMS content pages, including using CMS templates as layouts, being able to throw exceptions like 404s to route to the standard CMS error page, etc. Also added more hooks for securing controllers as though they were in a particular section. Developers can 'include Cms::Acts::ContentPage' in their controllers to get access to this behavior.

Upgrade Notes:
--------------

When upgrading from 3.0.6 to 3.1, there are several things to keep in mind mostly related to how the new editor works.

1. You can safely delete the public/fckeditor directory from your project. We have moved the default location that modules (like bcms_fckeditor) store public files to public/bcms/module_name (so public/bcms/fckeditor or public/bcms/ckeditor).
2. FCKEditor styles: If you customized your fckeditor styles (by editing the fckstyles.xml), install the bcms_fckeditor module and it will create a public/bcms_config/fckeditor directory. The fckstyles.xml can be edited there, which will keep it separate from the 'stock' files that fckeditor comes with.

More Features/Enhancements:
---------------------------

Lighthouse ticket #s are included:
* #199 - Developers should be able to manually set the display_name of content blocks. (See http://guides.browsercms.org/content_blocks.html for details).
* #234 - Added a cms_check_box field so content blocks can have single boolean values.
* #123 - Release the bcms_google_mini module as a gem. Allows for easy integration with the Google Mini Search tool for searching BrowserCMS sites.
* #190 - Changed cms_file_field helper so it uses a standard file browse button by default.
* #233 - When new modules are generated, there is now a public directory created by default (public/bcms/name_of_module). Developers can put files they need copied into projects into that directory when the module is installed.
* #198 - Added portlets that allow public users to reset their password if they have forgotten it.
* #295 - When creating a new project, it will explicitly set the version # of the browsercms gem. This should reduce the need to vendor the gem for servers that have multiple BrowserCMS sites.
* #299 - When generating a portlet, a portlet_helper will be created. All methods on this helper will be available in the portlet template view.
* #300 - For new projects, the 'default' template is now stored on the file system. This should make it more obvious to new developers that both file and database managed templates are possible.
* #301 - Created a generator for templates. ./script/generate template name_of_template will create a new erb template in the proper directory with some reasonable defaults.
* #205 - Developers can check if Users can view a particular section path (User.able_to_view?("/about-us").

Bug Fixes:
---------

* #208 - Fixed an issue where an error on the dashboard that was preventing BrowserCMS projects from using SQLlite.
* #161 - Fixed a typo on the Edit Group Permissions page. (Thanks to Dmytro Samodurov)
* #197 - Fixed an issue where an editor could not cancel deleting of a template.
* #204 - Fixed an error where pages/sections would not appear in menus when pages were moved or deleted.
* #206 - Fixed an error where sections should be marked with an 'on' state, even if the first page in the section is hidden. (Thanks to Kimmy/3months.com)
* #240 - Fixed an issue where users could publish blocks via the content library that were embedded into pages. This resulted in a counter intuitive state where users would think they were publishing pages when they were not.
* #221 - Updated render_breadcrumbs helpers so it will return an empty string if there is no current_page. This should make breadcrumbs behaves better if using Cms::Acts::ContentPage and page templates.
* #265 - Fixed an issue where users could only have a single task assignment. (Thanks to 3months.com)
* #278 - Fixed an issue where users with expiry dates would not appear in the task list (Thanks to kimmy/3months.com)
* #284 - Eliminated warnings about Version constants while running tests (Thanks to czarneckid)
* #294 - Fixed an issue where generating blocks with attachment fields would fail during migrations.
* #275 = Fixed an issue where admin users were sent links to public pages when they were assigned tasks. This made it hard for them to follow links to pages to make corrections to them.
* #263 - Fixed an issue where portlets embedded in pages would break pages if they were deleted.

v3.0.6
======

3.0.6 is a small bug fix release which should correct the big issues that were preventing use of 3.0.5. Here's the rundown:

1. The 'require_javacript_include' and 'require_stylesheet_link' methods were not working properly, and now they do.
2. You could not publish a changed link without modifying it in some way, and now you can. (LIGHTHOUSE #256)
3. You can now search for portlets and tags by name in the Content Library. (LIGHTHOUSE #257 and #258)
4. After creating or updating a category or tag via the Content Library, you are now redirected to the list page (as with Category Types) instead of being shown a blank page. (LIGHTHOUSE #259)
5. The user list in the Admin area now shows a user's login (instead of nothing) if the user does not have a name. (LIGHTHOUSE #260)

v3.0.5
======

BrowserCMS 3.0.5 has been released to gemcutter. This is primarily a bug fix release, correcting some IE support issues as well as some problems with reverting. We also made some subtle changes to how JS gets loaded on page templates in the CMS admin UI. If your project had been using its own javascript (like jquery/prototype) in the page templates, you should double check to make sure its working correctly.  See item #2 below for more details.

This is the first release directly to gemcutter and we will likely move to shutdown the rubyforge project since we are only it for gem hosting. Since GemCutter is now the default gem hosting environment this shouldn't really affect anybody.

The highlights of what has been fixed are as follows. You can also see the original tickets in Lighthouse here: https://browsermedia.lighthouseapp.com/projects/28481-browsercms-30/milestones/57844-305
 
Features/Enhancements:
1. Javascript and Stylesheet assets may be "required" from any template or partial via helper methods.  These methods add the asset to the header only if it has not already been added via a "required" statement.  This may be useful for developer who create portlets that rely on common javascript libraries like jquery. You can add a '<%= require_javascript_include "jquery" %>' to your portlet template and be assured it will only be added to the page template once. LIGHTHOUSE #248.

Bug Fixes:
1. Fixed an issue where you couldn't revert some pages/blocks. Attributes of draft versions could not be updated (or reverted) to the same attributes as the published version of the object.  This problem affected pages and versioned content blocks.  You can now update draft attributes to any value.  The feature in which a new draft is only created if there is a change still works.  LIGHTHOUSE #225.
2. Internet Explorer 7 could not remove blocks from page containers nor move blocks within page containers.  This problem seemed to be due to JavaScript permissions, as the iframe rendering the page toolbar could not attach the update form to the parent window.  The edit container now requires JavaScript (see the enhancement) in the actual page to build the update forms.  LIGHTHOUSE #229.
3. Search parameters were not included with pagination links in the Content Library, so clicking the "next page" link of the searched results would lose the search filter, thus showing results the user had previously filtered out.  Search parameters are now included in the pagination links.  LIGHTHOUSE #239.


v3.0.4
======

We found an unfortunate bug in the changes we introduced to the
"render menu" functionality in the 3.0.3 release.  We have quickly
patched this and have released the 3.0.4 gem on RubyForge. BrowserCMS 3.0.3 is now released and available for download. 

v3.0.3
======

The primary goal of this release was to incorporate the many community
patches/changes that folks have been providing over the past few
months. A lot of developers put some hard work and smart thinking into
these patches, so many thanks to everyone who contributed to helping
make BrowserCMS even just a little bit better.

As always,the complete list of fixes can be found in Lighthouse -
https://browsermedia.lighthouseapp.com/projects/28481-browsercms-30/t...

Release Notes:

1. Section editing permissions are now enforced. A CMS User must have
edit permission for a given section to add pages, links, or
subsections to it, as well as to edit the pages or links in that
section.  Only CMS Administrators may change permissions. Blocks that
appears in multiple sections can be edited only by someone with
permissions to edit all of the sections.  Patch supplied by Jon
Leighton, who incorporated the work of nachokb and webficient.

2. Portlets can force redirects to Access Denied and Page not found
pages by raising AccessDenied and RecordNotFound errors.  Patch
supplied by Jon Leighton.

3. Versioning no longer breaks "update_attribute" api.  Patch supplied
by nachokb.

4. Bug fixed in which Attachment Blocks could not have attachments
added to them if there was no attachment at creation. Patch supplied
by Joshua Vial.

5. Styles for containers improved to accommodate relative-width
formats.  Patch supplied by djcp.

6. File handling uses fileutils instead of ftools for Ruby 1.9
compatibility.  Patch supplied by ahaller.

7. Menu helper can now take an arbitrary tree of nodes.  Patch
supplied by Jon Leighton.

8. All unpublished pages publishable by the current user show up on
the dashboard.  Patch supplied by Jon Leighton.

9. If the login portlet has a success url set, this url overrides
wherever the user was trying to get to.  Patch supplied by Luciano
Ruete.

10. Bug fixed in which the routes in vendored gems overrode routes in
config.  Patch supplied by Jon Leighton.

11. Regular expression for email validation improved.  Patch supplied
by Joshua Vial.

12. Username in navigation now a link to view your account for non-
administrators.  Also added the ability to change your password.
Patch supplied by Jon Leighton.

13. Double-clicking a content item in the Content Library now takes
you to the edit (or view, if you are not allowed to edit) page.

14. Method added to Group to check if guest.

15. Added PSDs for some administrative buttons for use by those
working to improve the UI.

16. Deprecated cms:install rake task removed. 

v3.0.2
======

We just released the 3.0.2 release through rubyforge, and it includes
a few small fixes.
Daniel Collis-Puro supplied a patch for the cms_text_field
instructions float problem.
Content blocks ending with 'ss' were causing problems, and now they
don't.
You can add columns to both the block and version table with one line
in migrations now. 

For further info on what was changed, refer to this URL.
https://browsermedia.lighthouseapp.com/projects/28481-browsercms-30/t...
. It's pretty short list, but the instructions bug was quite
bothersome. We also have set up a Wiki for the project (on Github),
which can be found here: http://wiki.github.com/browsermedia/browsercms
.

The next release will be 3.0.3 and we are going to focus on rolling in
most of the community patches which folks have been sending pull
requests for, that we just haven't have a chance to get included. 

v3.0.1
======

I have just released 3.0.1 as a gem to ruby forge. This is mostly a  
bug fix release, with a few notable issues I will mention in this  
email. For a complete list of all the tickets fixed, see Lighthouse (https://browsermedia.lighthouseapp.com/projects/28481-browsercms-30/t...
)

h1. Release Notes
Here are some tickets fixed which might be of interest, along with the  
corresponding LH ticket #.

* #116 - Changed guide format to Textile: This should be more inline  
with how Rails guides works, which should make it easier for users to  
contribute to the documentation.
* #67 - render_menu can now cap how many nav items to show: This  
should help with menus that have a fixed amount of space (like  
horizontal nav), where you want at most X number of items to show, and  
you don't want to accidentally break your nav when adding an item to  
the sitemap.
* #66 - render_menu can now dynamically render nav items from specific  
sections: This helps with making 'utility' nav, where you might want  
items from a specific section to be consistent on all templates (for  
example, your 'contact us'/Sitemap/Directions to our office pages can  
be in a specific section).
* #121 - Sample modules are released as gems: All the modules (except  
google_mini) found here https://github.com/browsermedia can now be  
installed as gems from rubyforge (i.e. gem install bcms_news)
* #51 - Portlets can be configured to render views from the file  
system: Portlets by default use store the view in the database, so  
they can be editted through the UI at runtime. This option lets you  
have it use the copy on the file system, which should allow for quick  
edit cycles. (See doc/guides/html/developer_guide.html for details)

Haml Support for templates- There is no ticket # for this, but the  
Developers Guide has some instructions on how to use HAML for your  
portlet views as well.

Plus a number of reported bugs from LH.

h1. Docs
I will update browsercms.org sometime today with the latest version of  
the docs, but as always, you can find a copy with the latest source  
code.

h1. Issues
If folks run into issues w/ 3.0.1, please report them in Lighthouse (https://browsermedia.lighthouseapp.com/projects/28481-browsercms-30
), to be fixed in 3.0.2. 
