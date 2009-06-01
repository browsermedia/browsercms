# BrowserCMS: Humane Content Management for Rails

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

## Browser Compatibility
BrowserCMS can create websites that can work in any browser, depending on how developers implement their design as HTML templates. However, the administrator interface is limited to a select # of browsers, with Firefox being the most stable. Supported browsers include:

1. FireFox 3+ (Mac, Windows, Linux) - This is currently the best choice for administering the CMS.
2. Safari 3.2+ (Mac, Windows) - Works, with some minor layout problems.
3. Internet Explorer 7+ (Windows) - Mostly functional, though there are a number of layout issues in the admin.

The next releases will be aimed at tightning up the admin for both Safari and IE7+. We will not be supporting the admin UI for IE6, or other browsers not explicitly listed above.

## Getting Started
Before you can use BrowserCMS, you will need to install the gem. See the Getting Started guide at http://browsercms.org/doc/guides/html/getting_started.html, or packaged with this source code (under doc/guides/html/getting_started.html)

## License
BrowserCMS is released under a LGPL license, and is copyright 1998-2009 BrowserMedia. The complete copyright can be found in COPYRIGHT.txt, and copy of the license can be found in LICENSE.txt.


## Documentation
The user documentation and guides for this version of the application can be found at:

1. http://browsercms.org/doc/guides/html/index.html - User guides and manuals that cover the features and general functionality of the project. (Found locally at doc/guides/html/index.html)
2. http://browsercms.org/doc/app/index.html - The RDoc API documenation (locally at doc/app/index.html)

## Modifying the source
If you want to experiment with the source code, the BrowserCMS project can bootstrap itself as a web application. This allows developers who want to contribute to the project to easily alter and test changes. To run the application itself, do the following:

    cd /path/to/browsercms_source_code
    rake reset
    script/server

This will drop the 'browsercms_development' database, loads the same sample data from the demo.rb template. By default, the core project is setup to use mysql as the database, but you can change that via the database.yml files.

## Support
The homepage for the BrowserCMS project is http://browsercms.org. From there you can find links to the discussion groups and our twitter account. If you have questions about the project or want to get involved, the Google group is the best way to do so. If you would like to report a bug, please do so at https://browsermedia.lighthouseapp.com/projects/28481-browsercms-30
