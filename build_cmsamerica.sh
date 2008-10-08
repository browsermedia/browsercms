#!/bin/sh

#
# Script to generate cmsamerica.  
#

#You probably need to update this path if running on a different machine
CMS_PATH="/Users/pbarry/perforce/depot/cmsamerica(new)"

#Install CMS gem
gem build gemspec.rb
sudo gem install BrowserCMS-3.0.0.gem --no-ri --no-rdoc

#Create rails skeleton for CMSAmerica
cd ..
if [ -d cmsamerica ] 
  then
    rm -rf cmsamerica
fi
rails cmsamerica -d mysql
cd cmsamerica

#Make edits to the configuration
ruby -pi -e "gsub(/# config.gem \"aws-s3\", :lib => \"aws\\/s3\"/, 'config.gem \"BrowserCMS\", :lib => \"cms\"')" config/environment.rb
ruby -pi -e "gsub(/boot/,'environment')" Rakefile
echo -e "\nload \"#{Cms.root}/lib/tasks/cms.rake\"\n" >> Rakefile
rake db:create:all

#copy assets like images, javascript, stylesheets from gem into the project
rake cms:install 

#Import the data from the old DB to the Rails DB
rake cms:import CMS_PATH=$CMS_PATH CMS_DB_NAME=cmsamerica --trace
    