# BrowserCMS: Humane Content Management for Rails

This is a fork to extract UI strings to make it possible to use BrowserCMS in languages other than English.
I am using the built in I18n module with the simple backend, so there is no need to install or do
anything special. 

## Try it out
    
    git clone git@github.com:alce/browsercms.git 
    cd browsercms
    # make sure you are on the lit branch
    # configure database.yml
    rake reset
    script/server
    
If you run the above commands you should see no difference in BrowserCMS's UI. If you do, then
you found a bug!. Edit the file config/initializers/i18n.rb and change the locale to spanish 
(only Spanish and English translations are available but you can create your own)

    I18n.default_locale = :es
    
Copy the 12 images located at doc/design/es to public/images/cms replacing the original ones,
restart your server and you should see (most) of the UI in Spanish.


## Pending transaltions

This is a work in progress. Most of the view files have been prepared for translation (and 
translated to spanish) but there are a few still pending. Some work still needs to be done, 
particularly on:

* Portlets
* Javascripts (there are at least a couple of functions that manipulate toolbar buttons)
* Helpers
* Models (some models output strings that need translation)

## Images

The main toolbar has 4 links that use images: My Dashboard, Sitemap, Content  Library and Administration.
To translate these, you need to create 12 images. 3 for each link (over, up and active states)
You can use a .psd file that was added to the repository a while back. It's on doc/design. 

Once you have your images, just replace the original ones.

1. public/images/cms/nav_admin.gif
2. public/images/cms/nav_admin_h.gif
3. public/images/cms/nav_admin_on.gif
4. public/images/cms/nav_content_library.gif
5. public/images/cms/nav_content_library_h.gif
6. public/images/cms/nav_content_library_on.gif
7. public/images/cms/nav_dash.gif
8. public/images/cms/nav_dash_h.gif
9. public/images/cms/nav_dash_on.gif
10. public/images/cms/nav_sitemap.gif
11. public/images/cms/nav_sitemap_on.gif
12. public/images/cms/nav_sitemap_h.gif

## Creating your own locale files

## Contact
Juan Alvarez
com{{dot}}mac[[at]]alce
  

    

