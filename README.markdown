# BrowserCMS: Humane Content Management for Rails

(3.0 Beta) - Not quite done, but ready to be tinkered with.

BrowserCMS is a general purpose, open source Web Content Management System (CMS), written in Ruby on Rails. It is designed to support three distinct groups of people:

1. Non-technical web editors who want a humane system to manage their site, without needing to understand what HTML or even Rails is.
2. Designers who want to create large and elegantly designed websites with no artificial constraints by the CMS.
3. Developers who want to drop a CMS into their Rails projects, or create CMS driven websites for their clients.

## Features
BrowserCMS is intended to offer features comparable to commercial CMS products, which can support larger teams of editors. This means having a robust set of features as part of its core, as well as the capability to customize it via modules. 

Here's a quick overview of some of the more notable features:

* It's just Rails: Each CMS project is a rails project that depends on the BrowserCMS gem. Developers can add new controllers, views, etc; just like any rails project.
* Direct in context editing: Users can browse their site to locate content and change it right on the page itself.
* Design friendly Templates: Pages aren't just a template and giant single chunk of HTML. Templates can be built to have multiple editable areas, to allow for rich designs that are still easy to manage by non-technical users.
* Sitemap: An explorer/finder style view of sections and pages in a site allowing users to add and organize pages.
* Content Library: Provides a standardized 'CRUD' interface to allow users to manage both core and custom content types.
* Content API: A set of behaviors added to ActiveRecord which allow for versioning, auditing, tagging and other content services provided by the CMS.
* Section Based Security: Admins can control which users can access specific sections (public users), as well as who can edit which pages (cms users).
* Workflow: Supports larger website teams where some users can contribute, but not publish. Users can assign work to other publishers to review.
* Page Caching: Full page caching allows the web server (Apache) to serve HTML statically when they don't change.

## License
BrowserCMS is released under a LGPL license, and is copyright 1998-2009 BrowserMedia. The complete copyright can be found in COPYRIGHT.txt, and copy of the license can be found in LICENSE.txt.

## Installation
BrowserCMS is packaged as a gem, which can be included in any Rails project. The gem contains the code for the cms application itself. It also has a lot of public assets, including stylesheets, images and javascript, which will be copied from the gem as part of the install process. This section assumes that:

1. There is no gem available on rubyforge yet. (Because we haven't released yet)
2. You have downloaded the source code from github
3. You want to build the gem locally and install it.
4. You already have Rails 2.3 installed.

## Building the gem
To build the gem from source, and install it on your system, type the following:

    git clone git://github.com/browsermedia/browsercms.git
    cd browsercms
    rake install

On *unix, this will sudo install, so you will need to provide your password.  The gem management is now handled with <a href="http://technicalpickles.github.com/jeweler">Jeweler</a>, so you must install Jeweler to install the gem.

## Starting a new project
The next step is to create a rails project, which will include BrowserCMS, much like you would with any rails project. To make things easier, BrowserCMS comes with two application templates (a feature new to Rails 2.3), which create the initial rails application, configured for BrowserCMS. For now, you need to use the app templates from the source directory of cms. Here are the two options when starting a project.

* /templates/demo.rb - If you are new to BrowserCMS, and want to experiment, use this. It builds a sample site with a few pages, using our default theme, and adds some content to play around with.
* /templates/blank.rb - Use this if you want a completely empty site. Most 'real' projects will use this to start, as there is no 'dummy' data to remove before building a site.

To create a new project (using the demo template), run the following:

    cd ~/projects
    rails my_new_project_name -m /path/to/browsercms_source_code/templates/demo.rb
    cd my_new_project_name
    script/server

This is going to create the development and testing copies of the database, migrate the db, populate it with some initial data, and copy all of the necessary files from the gem into the rails project.

From here, you can go to http://localhost:3000 to see the running CMS application. To log into the admin for the CMS, go to http://localhost:3000/cms, and type in the username and password. The default when running in dev mode is username=cmsadmin, password=cmsadmin. 

## Documentation
The user documentation and guides for this version of the application can be found at:

1. doc/guides/html/index.html - User guides and manuals that cover the features and general functionality of the project.
2. doc/app/index.html - The RDoc API documenation.

## Modifying the source
If you want to experiment with the source code, the BrowserCMS project can bootstrap itself as a web application. This allows developers who want to contribute to the project to easily alter and test changes. To run the application itself, do the following:

    cd /path/to/browsercms_source_code
    rake reset
    script/server

This will drop the 'browsercms_development' database, loads the same sample data from the demo.rb template. By default, the core project is setup to use mysql as the database, but you can change that via the database.yml files.

## Support
The homepage for the BrowserCMS project is http://browsercms.org. From there you can find links to the discussion groups and our twitter account. If you have questions about the project or want to get involved, the Google group is the best way to do so. If you would like to report a bug, please do so at https://browsermedia.lighthouseapp.com/projects/28481-browsercms-30
