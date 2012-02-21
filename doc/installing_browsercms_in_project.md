# Things to note

* The CMS 'homepage' is technically at the path /, however its highly likely your default route will get served first. This may cause issues with:
- Users that log in to /cms will end up on default route
- Clicking the CMS logo will take users to the default route.

* rake db:install will run db:seed (again) for projects, which may not be acceptable. Need a separate rake task for seeding CMS data.
