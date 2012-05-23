Tasks:

* [BUG] Email Page portlet handler_path isn't generating a correct URL for a given email/portlet (There is failing scenario for this.) Probably related to how view helpers are added to portlets.

# 4.0.x

* [REFACTOR] Remove bcms-upgrade as a separate bin

# 3.6.x

* Browser Compatibility Testing - Ensure compatibility with latest versions of Chrome/IE 9/Firefox/Safari. IE 9 probably needs the most works.
* Simplify Table Prefixing: How much value is there to allow users to pick the table prefix (as compared to the complexity it brings). Would it be better to just force everything to cms_?


# 3.4.x

* [CMS] Upgrade a 3rd module (with a migration) to confirm the installation and upgrade instructions work correctly.
* browsercms-cucumber - Build a separate gem from this project, which can be included in other CMS projects. (Might be 3.4.1)
* Refactor Cucumber steps to add seed data once as part of the env.rb file, then use truncation to leave it there.
* If user's try to add to a Rails 3.2 project, it will blow up midway through (i.e. the jquery-rails dependency will fail since R3.2 require jquery-rails-2.0. A better plan would be to fail fast.

## Unscheduled Future Ideas

### Publishing/Versioning Improvements:
* Add Block.publish and publish! for easier coding. (or just make default for blocks to be published via code and not via UI)

- The mess that is publishing/saving is coming back again when trying to interact with blocks with associated attachments.
-- Really need to simplify this API as its very painful to grok and get right currently.
-- Key issue: For existing blocks, these two statements are not the same:
a. @block.publish_on_save = true; @block.save
b. @block.publish!
When almost certainly should be.
- Another Versioning related Bug: Blocks with has_many :autosave=>true does not work. The callbacks do not trigger when the block is saved.

###  Misc Ideas
* Internal CMS layouts (like _head.html.erb) do not take advantage of the asset pipeline to join all css or js files (most are compiled into cms/application.css though)
* Improve generators for assets from engines (Review http://bibwild.wordpress.com/2011/09/20/design-for-including-rails-engine-assets-into-pipeline-manifest/)
* Themes can be packaged as assets as well (I think?). Rework bluesteel so its part of the asset pipeline.
* Design how a portlet can include a single jquery based library by just declaring it in the render.html.erb.
** eg. auto_discovery_link_tag -> Does not get included in the head
* Allow for multiple view templates for blocks.
* Look at Papertrail and see how they structure versions. Their API seems every simple for single blocks.
* Upgrade jquery.selectbox-0.5 to jquery.sb.js (https://github.com/revsystems/jQuery-SelectBox). This will likely improve the usability of the selectbox.

## Better Testing of Production/Env

### Using Pow
Configure a CMS application to boot in production mode (temporarily for testing). Assumes powder is installed.

#### With a New project
bcms new [project_name]
echo "rvm use 1.9.3@r3.2" > .rvmrc
powder install
Open Browser to http://project-name.dev

echo export RAILS_ENV=production > .powenv && touch tmp/restart.txt - From https://github.com/37signals/pow/wiki/FAQ