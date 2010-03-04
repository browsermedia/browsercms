# BrowserCMSI: Humane Content Management for Rails

This is a fork to extract UI strings and make it possible to use BrowserCMS in languages other than English.
I am using the built in I18n module with the simple backend, so there is no need to install or do
anything special. 

## Installation
    
    gem install browsercmsi
    
## Creating a new project

* run bcmsi my_project
* edit the file config/initializers/i18n.rb and set the default locale (at the moment only English and Spanish are available) 
* run rake db:migrate
* start your server

## Translating BrowserCMS

If your are not already familiar with the [Rails Internationalization API](http://guides.rubyonrails.org/i18n.html), 
it might be a good idea for you to take a quick look at it first.

To translate BrowserCMS' UI to a new language you need to create your new locale files and 12 images
for the main toolbar. 

### Creating locale files

* Create a new directory under config/locales/bcms and name it after the locale you intend to use.
  For example, if you are going to translate BCMS to French, you would create a directory named fr.
* Copy over all the files from one of the available locales to your newly created locale directory and change
  the locale key.
* Restart your server and start translating.

You can swap between locales using the buttons at the top of the toolbar. You'll see one button for
each locale key you have on your installation. You will not see these buttons on a production site
since their purpose is only to let you swap locales while you are translating the UI to a new language
during development. Not only you will not see the buttons on production but the route to swap locales
is not even mapped. 

**Note about locale keys**  Although neither Rails or BrowserCMSI really care which locale keys you use,
if you use the  ISO 639-1 code for your language, BrowserCMSI will set CKEditor locale automatically for you. If you
use non-standard locale keys, CKEditor will fallback to English. 

### Toolbar images

BCMS uses 4 sets of images for the links in the main toolbar: My Dashboard, Sitemap, Content Library and Administration.
You need to create one image for the up, over and active states of each link. You can use a .psd file
located in doc/design on this repository. (Take a look at public/images/cms/locales/en and name your new images accordingly)

Once you have your images, you need to place them in a new directory under public/images/cms/locales. Name
this directory exactly the same as your locale files directory. (fr to continue with the french example).

## Translating seed data

When you run rake db:migrate after creating a new project, BrowserCMS seeds some data on the database.
The locale file for these records is bootstrap.yml. Changes made to this locale file will not take
effect when you change the locale (either with the toolbar buttons or in the initializer i18n.rb).
You'll need to run the migrations again to see these changes.

    rake db:migrate VERSION=0
    rake db:migrate


## Locale files organization

There is really no 'correct' way to organize the locale files. As far as the Rails i18n API is
concerned, you can place all translation strings in a single file so you can move them around
as you see fit as long as the data structure represented in YAML files does not change.

When organizing the locale files (and the Hash structure) I tried to find a balance between
having a logical, easy to follow structure and not having insanely long key paths.

Locale files are organized in a way that 'mostly' resembles BrowserCMS's file structure so it should
be very easy to follow what goes where. The bulk of the translation work is done in views
and layouts.

Here's a brief description of the files:

* **behaviors.yml** contains translation strings for a few BCMS' modules that add behaviors to
  models. -> lib/cms/behaviors/*
* **bootstrap.yml**  contains translation string for BCMS's migrations.  -> db/migrate/*
* **controllers.yml** contains flash messages translation strings -> app/controllers/cms/*
* **helpers.yml** contains translation strings for helpers. -> app/helpers/cms/*
* **js.yml** contains translations strings for javascript functions. -> public/javascripts/cms/sitemap.js
* **models.yml** contains standard ActiveRecord model, attribute and error messages translation strings 
  plus some custom BCMS' instance and class methods -> app/models/*
* **portlets.yml** contains translation strings for BCMS' bulit in portlets -> app/portlets/*
* views/ contains translation strings for BCMS' views -> app/views/**/*

## Versioning

BrowserCMSI's only concern is to localize BrowserCMS' UI. It does not add, remove or modify 
BrowserCMS's core features in any way. As such, BrowserCMSI's versioning mirrors BrowserCMS'.


## Contact
Juan Alvarez
alce{{at}}mac[[dot]]com
  

    

