# We can't just call `rails _2.3.14_ new` because Aruba locks to a specific version of the gem (I think).
# So we always get a Rails 3.1 project.
# Instead, we are 'faking' it.
Given /^I am working on a BrowserCMS v3.1.x module named "([^"]*)"$/ do |project_name|
  write_file "#{project_name}/script/console", "# Rails 2 File"
  cd project_name
  write_file "lib/#{project_name}.rb", "# Marks this as a Module."
  create_git_project
end

When /^the installation script should be created$/ do
  steps %Q{
  And the following directories should exist:
      | lib/generators/bcms_widgets/install/templates |
    And the following files should exist:
      | lib/generators/bcms_widgets/install/USAGE                |
  }
  generator = 'lib/generators/bcms_widgets/install/install_generator.rb'
  check_file_presence([generator], true)
  check_file_content(generator, "BcmsWidgets::InstallGenerator", true)
  check_file_content(generator, "rake 'bcms_widgets:install:migrations'", true)
  check_file_content(generator, "mount_engine(BcmsWidgets)", true)

end
When /^the engine should be created$/ do
  check_file_presence(['lib/bcms_widgets.rb'], true)
  check_file_content('lib/bcms_widgets/engine.rb', "include Cms::Module", true)

end

Then /^a Gemfile should be created$/ do
  steps %Q{
  Then a file named "Gemfile" should exist
        }
end

When /^it should no longer generate a README in the public directory$/ do
  check_file_presence [' public/bcms/bcms_widgets/README '], false
end

When /^the project should be LGPL licensed$/ do
  check_file_presence ['GPL.txt', 'LICENSE.txt'], true
  check_file_presence ['MIT-LICENSE'], false
end

