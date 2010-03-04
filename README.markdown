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

If your are not already familiar with Rails Internationalization API, it might be a good idea for you
to take a quick look at http://guides.rubyonrails.org/i18n.html 

To translate BrowserCMS' UI to a new language you need to create your new locale files and 12 images
for the main toolbar. 

### Creating locale files

* Create a new directory under config/locales/bcms and name it after the locale you intend to use.
  For example, if you are going to translate BCMS to French, you would create a directory named fr.
* Copy over all the files from one of the available locales to your newly created locale directory and change
  the locale key.
* Restart your server and start translating.

**Note about locale keys**  Although neither Rails or BrowserCMSI really care which locale keys you use,
if you use the  ISO 639-1 code for your language, BrowserCMSI will set CKEditor locale automatically for you. If you
use non-standard locale keys, CKEditor will fallback to English. 

### Toolbar images

BCMS uses 4 sets of images for the links in the main toolbar: My Dashboard, Sitemap, Content Library and Administration.
You need to create one image for the up, over and active states of each link. You can use a .psd file
located in doc/design on this repository.

Once you have your images, you need to place them in a new directory under public/images/cms/locales. Name
this directory exactly the same as your locale files directory. (fr to continue with the french example).


## Locale files organization

## Contact
Juan Alvarez
com{{dot}}mac[[at]]alce
  

    

