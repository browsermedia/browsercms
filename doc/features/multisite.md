Tasks for Multisite

* /sites/nameofsubsite.com/modules
* /sites/nameofsubsite.com/themes
* /sites/nameofsubsite.com/setting.rb = database settings
* Ideally, it should be possible to add new folders/files to define additional subsites.


To start:

* Assume all templates and all modules available to all sites.
* Add POW so it works with a second site. (microsite.dev)


## Release Notes

* Removed existing Site class since it did not do anything real.

## Getting Started

Need to create identical .rvmrc in both / and /test/dummy. I.e.
    rvm use 1.9.3@browsercms-4.x

Use POW for two domains (browsercms.dev and microsite.dev). Require steps:

gem install powder
cd test/dummy
powder link browsercms
rm .powder
powder link microsite
rm .powder

Now both browsercms.dev and microsite.dev point to same app.


