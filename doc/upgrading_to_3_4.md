Update bcms-upgrade so it can detect the differences between:

3.1
3.3 (Already does this pretty well)
* If there are no errors, say 'its ready to go' rather than just warning in RED that its does now.
* Need to update the dependency on browsercms before running rails generators
	(Insert s.add_dependency(%q<browsercms>, ["~> 3.3.0"]) into .gemspec
* I can generate a basic gemspec that will probably work for 95% of cms modules.
* Doesn't use mysql2 '0.2.18'
* Make sure cms:install works
3.4 (Needs to do this)
* Might still want to have a custom installer for each module for generating files in the project (i.e. Fckeditor would need this)

# Upgrading a project to bcms-3.4

* Ensure there is no table prefix set (i.e. tables will in versions prior to 3.4 were not prefixed with cms_

# Upgrading a module to bcms-3.4

Starting with a bcms-3.3 module (i.e. bcms_news)

* rm -rf script
* rm config.ru
* Run rails plugin new . --mountable --force
** Creates a test/dummy app
** Resolve/rollback as needed.
* rm MIT-LICENSE
* rm README.rdoc
* Move config/database.yml -> test/dummy/config/database.yml
* Empty config/*
* Delete the install generator (No longer necessary)
    /lib/generators/bcms_news/install/*
* Update the .gemspec as needed
* Edit lib/bcms_news/engine.rb to start with:
    require 'browsercms'

* Delete all browsercms migrations from db/migrate. Leave projects specific ones.
* Copy routes from lib/bcms_news/routes.rb to config/routes.rb.
** rm lib/bcms_news/routes.rb
* rm -rf app/views/layouts
* rm app/helpers/application_helper.rb
* rm app/controllers/application_controller.rb
* rm app/controllers/bcms_news/application_controller.rb
* mv public/bcms_news into assets
* rm -rf public
* Add mount_browsercms to test/dummy/config/routes.rb (Must be last)
* Copy the browsercms.seeds.rb into the project (Need to improve this). Add a seeds.rb that points to it.
* Add require 'jquery-rails' in test/dummy/config/application.rb (Bug with Rails -> See http://www.ruby-forum.com/topic/2484569)
* Edit any migrations to namespace Cms:: i.e.
    Cms::ContentType
    Cms::CategoryType
* Edit any portlets/blocks/controllers and namespace references to cms classes
* cd test/dumy && bundle exec rake railties:install:migrations
** Might require deleting existing migration (from gem)
** bundle exec rake db:drop db:create db:migrate db:seed

* Make sure YourEngine::Engine has:

    include Cms::Module


* Move/namespace Controllers under BcmsNews:: (app/controllers/bcms_news)
* Add a migration to rename the table to start with: bcms_news_
* Retimestamp migrations so browsercms migrations (in test/dummy/db/migrate) come before your engines migrations.


