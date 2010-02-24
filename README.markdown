# BrowserCMS: Humane Content Management for Rails

This is a fork to extract UI strings to make possible to use BrowserCMS in languages other than English.
I am using the built in I18n module with the simple backend.

## Try it out
    
    git clone git@github.com:alce/browsercms.git 
    cd browsercms
    # make sure you are on the lit branch
    # configure database.yml
    rake reset
    script/server
    
If you run the above commands you should see no difference in BrowserCMS's UI. Edit the
file config/initializers/i18n.rb and change the locale to spanish (only spanish and english 
translations are available but you can create your own)

    I18n.default_locale = :es
    
Restart your server and you should see (most) of the UI in Spanish.


## Pending transaltions

This is a work in progress. Most of the view files have been prepared for translation (and 
translated to spanish) but there are a few still pending. Some work still needs to be done, 
particularly on:

* Controllers (to translate flash messages)
* Portlets
* Javascripts (there are at least a couple of functions that manipulate toolbar buttons)
* Helpers 

## Images

The main toolbar has 4 links that use images: My Dashboard, Sitemap, Content  Library and Administration.
To translate these, you need to create 12 images. 3 for each link (over, up and active states)
Yo can use a .psd file that was added to the repository a while back. It's on doc/design.

Once you have your images you can:

* Replace the original images on public/images/cms with your own or
* Place them wherever you want and adjust the paths on the file config/locales/es/views/layouts/cms_toolbar.yml

## Creating your own locale files
  

    

