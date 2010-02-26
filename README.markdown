# BrowserCMS: Humane Content Management for Rails

This is a fork to extract UI strings to make it possible to use BrowserCMS in languages other than English.
I am using the built in I18n module with the simple backend, so there is no need to install or do
anything special. 

## Try it out
    
    git clone git@github.com:alce/browsercms.git 
    cd browsercms
    # make sure you are on the lit branch
    # configure database.yml
    rake db:create
    rake db:migrate
    rake db:load_demo_data
    script/server
    
If you run the above commands you should see no difference in BrowserCMS's UI (except for a couple of new
buttons at the top of the toolbar). If you do, then you found a bug!. 

You can switch between the available locales on your installation by clicking on 
the locale links at the top of the toolbar. These links are only for development purposes and will not be present 
on a production site.

To choose a locale for a production site, you need to edit the file config/initializers/i18n.rb and 
explicitly set the default locale.

    I18n.default_locale = :es

## Images

The main toolbar has 4 links that use images: My Dashboard, Sitemap, Content  Library and Administration.
To translate these, you need to create 12 images. 3 for each link (over, up and active states)
You can use a .psd file that was added to the repository a while back. It's on doc/design. 

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

## Pending transaltions

This is a work in progress. Most of the application has been prepared for translation (and 
translated to spanish) but there is still some work to be done, particularly when loading
seed and sample data.

## Creating your own locale files

## Contact
Juan Alvarez
com{{dot}}mac[[at]]alce
  

    

